import 'package:petitparser/petitparser.dart';

import '../graphics/background.dart';
import '../graphics/graphics.dart';
import '../graphics/meta_tile.dart';
import '../source_info.dart';
import 'gbdk_tile_converter.dart';

class SourceParser {
  late Parser _parser;

  SourceParser() {
    _buildParser();
  }

  void _buildParser() {
    // Whitespace and comments
    final whitespace = anyOf(' \t\n\r');
    final lineComment = string('//') & any().starLazy(char('\n'));
    final blockComment = string('/*') & any().starLazy(string('*/'));
    final comment = lineComment | blockComment;
    final ws = (whitespace | comment).star();

    // Integer type patterns - order matters for longest match first
    final integerType =
        string('unsigned char') |
        string('uint8_t') |
        string('UINT8') |
        string('char');

    // Identifier (array name)
    final identifier =
        (letter() | char('_')) & (letter() | digit() | char('_')).star();
    final arrayName = identifier.flatten();

    // Array size (optional)
    final number = digit().plus().flatten().map(int.parse);
    final arraySize = char('[') & ws & number.optional() & ws & char(']');

    // Hexadecimal number
    final hexDigit = pattern('0-9A-Fa-f');
    final hexNumber = (string('0x') & hexDigit.plus().flatten()).map(
      (parts) => int.parse(parts[1], radix: 16),
    );

    // Decimal number
    final decimalNumber = digit().plus().flatten().map(int.parse);

    // Integer value
    final integerValue = hexNumber | decimalNumber;

    // Array element
    final arrayElement = ws & integerValue & ws & char(',').optional();

    // Array content
    final arrayContent = char('{') & ws & arrayElement.star() & ws & char('}');

    // Complete array definition
    final arrayDefinition =
        string('const').optional() &
        ws &
        integerType &
        ws &
        arrayName &
        ws &
        arraySize.optional() &
        ws &
        char('=') &
        ws &
        arrayContent &
        char(';').optional();

    // Use `token()` so we get offset information
    _parser = arrayDefinition.token().map((token) {
      final parts = token.value;

      //String type = parts[2] as String;
      String name = parts[4] as String;
      //final sizeInfo = parts[6];
      final arrayContentResult = parts[10] as List;

      final elementsResult = arrayContentResult[2] as List;
      final values = <int>[];

      for (final element in elementsResult) {
        if (element is List && element.length >= 2) {
          final value = element[1];
          if (value is int) values.add(value);
        }
      }

      //int? size;
      //if (sizeInfo != null && sizeInfo is List && sizeInfo.length >= 3) {
      //  final sizeValue = sizeInfo[2];
      //  if (sizeValue is int) size = sizeValue;
      //}

      return Graphics(name: name, data: values);
    });
  }

  Graphics? parseArray(String input) {
    try {
      final result = _parser.parse(input);
      return result.value;
    } catch (_) {
      return null;
    }
  }

  List<Graphics> parseAllArrays(String cSource) {
    final arrays = <Graphics>[];
    final lines = cSource.split('\n');

    String currentBlock = '';
    bool inArrayDefinition = false;
    int braceCount = 0;
    int arrayStartOffset = 0;
    int offset = 0;
    bool foundEquals = false;
    bool foundOpenBrace = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty ||
          trimmedLine.startsWith('//') ||
          trimmedLine.startsWith('/*')) {
        if (inArrayDefinition) {
          currentBlock += '\n$line';
        }
        offset += line.length + 1; // +1 for newline
        continue;
      }

      if (!inArrayDefinition && _looksLikeArrayStart(trimmedLine)) {
        inArrayDefinition = true;
        foundEquals = line.contains('=');
        foundOpenBrace = line.contains('{');
        currentBlock = line;
        arrayStartOffset = offset; // Track where the array definition starts
        braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
      } else if (inArrayDefinition) {
        currentBlock += '\n$line';

        // Check if we found the equals sign on this line
        if (!foundEquals && line.contains('=')) {
          foundEquals = true;
        }

        // Check if we found the opening brace on this line
        if (!foundOpenBrace && line.contains('{')) {
          foundOpenBrace = true;
        }

        braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
      }

      // Only try to parse when we've found equals, opening brace, and closed all braces
      if (inArrayDefinition &&
          foundEquals &&
          foundOpenBrace &&
          braceCount <= 0) {
        int arrayEndOffset =
            offset + line.length; // Track where the array definition ends

        final parsed = parseArray(currentBlock);
        if (parsed != null) {
          arrays.add(
            Graphics(
              name: parsed.name,
              data: parsed.data,
              startOffset: arrayStartOffset,
              endOffset: arrayEndOffset,
            ),
          );
        }
        inArrayDefinition = false;
        foundEquals = false;
        foundOpenBrace = false;
        currentBlock = '';
        braceCount = 0;
      }

      offset += line.length + 1;
    }

    return arrays;
  }

  bool _looksLikeArrayStart(String line) {
    final intTypes = ['uint8_t', 'unsigned char', 'char', 'UINT8'];

    // Check if line contains an integer type and has array brackets
    return intTypes.any(
          (type) => line.toLowerCase().contains(type.toLowerCase()),
        ) &&
        line.contains('[');
  }

  /// Export edited graphics back to source code
  /// Replaces the array definition with new values while preserving formatting
  String exportEdited(Graphics graphic) {
    if (graphic.sourceInfo == null ||
        graphic.sourceInfo!.dataType != DataType.sourceCode) {
      throw Exception('No source code available for export');
    }

    final sourceContent = graphic.sourceInfo!.content as String;

    // Parse all arrays to find the one matching our graphic
    final allArrays = parseAllArrays(sourceContent);

    // Add back the suffix based on graphic type
    String nameToSearch = graphic.name;
    if (graphic is MetaTile) {
      nameToSearch = '${graphic.name}_tiles';
    } else if (graphic is Background) {
      nameToSearch = '${graphic.name}_map';
    }

    final matchingArray = allArrays.firstWhere(
          (arr) => arr.name == nameToSearch,
      orElse: () =>
      throw Exception('Array $nameToSearch not found in source'),
    );

    // Extract the original array definition substring
    final originalDef = sourceContent.substring(
      matchingArray.startOffset,
      matchingArray.endOffset,
    );

    // Generate new array content with proper formatting
    List<int> data = [];
    if (graphic is MetaTile) {
      data = GBDKTileConverter().getRawTileInt(
        GBDKTileConverter().reorderFromCanvasToSource(graphic),
      );
    } else if (graphic is Background) {
      data = graphic.data;
    }

    final newArrayContent = _generateArrayContent(data, originalDef);

    // Replace the old array with the new one
    final before = sourceContent.substring(0, matchingArray.startOffset);
    final after = sourceContent.substring(matchingArray.endOffset);

    return before + newArrayContent + after;
  }

  /// Generate formatted array content matching the original style
  String _generateArrayContent(List<int> data, String originalDef) {
    // Extract the array declaration part (everything before the '=')
    final equalsIndex = originalDef.indexOf('=');
    if (equalsIndex == -1) {
      throw Exception('Invalid array definition: missing "="');
    }

    final declaration = originalDef.substring(0, equalsIndex + 1).trim();

    // Determine if original used hex format
    final usesHex = originalDef.contains('0x') || originalDef.contains('0X');

    // Detect indentation from original
    final lines = originalDef.split('\n');
    String indent = '';
    if (lines.length > 1) {
      // Find first line with array values
      for (final line in lines) {
        if (line.contains('{') || line.trim().startsWith('0')) {
          final match = RegExp(r'^(\s+)').firstMatch(line);
          if (match != null) {
            indent = match.group(1)!;
            break;
          }
        }
      }
    }

    // Determine items per line from original formatting
    int itemsPerLine = 8; // default
    if (lines.length > 1) {
      for (final line in lines) {
        final commaCount = ','.allMatches(line).length;
        if (commaCount > 0) {
          itemsPerLine = commaCount + 1;
          break;
        }
      }
    }

    // Generate formatted values
    final buffer = StringBuffer();
    buffer.write('$declaration {\n');

    for (int i = 0; i < data.length; i++) {
      if (i % itemsPerLine == 0) {
        buffer.write(indent);
      }

      if (usesHex) {
        buffer.write(
          '0x${data[i].toRadixString(16).padLeft(2, '0').toUpperCase()}',
        );
      } else {
        buffer.write(data[i].toString());
      }

      if (i < data.length - 1) {
        buffer.write(',');
        if ((i + 1) % itemsPerLine == 0) {
          buffer.write('\n');
        } else {
          buffer.write(' ');
        }
      } else {
        buffer.write('\n');
      }
    }

    buffer.write('};');

    return buffer.toString();
  }

  /// Convenience method to export and update sourceInfo
  Graphics exportAndUpdate(Graphics graphic) {
    final newSource = exportEdited(graphic);

    return graphic.copyWith(
      sourceInfo: graphic.sourceInfo!.copyWith(content: newSource),
    );
  }
}
