import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';
import 'package:petitparser/petitparser.dart';

class SourceParser {
  late Parser<Graphics> _parser;

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

    // Integer type patterns - create individual parsers and combine them
    final integerType =
        string('unsigned char') | string('uint8_t') | string('UINT8');

    // Identifier (array name)
    final identifier =
        (letter() | char('_')) & (letter() | digit() | char('_')).star();
    final arrayName = identifier.flatten();

    // Array size (optional)
    final number = digit().plus().flatten().map(int.parse);
    final arraySize = char('[') & ws & number.optional() & ws & char(']');

    // Hexadecimal number
    final hexDigit = pattern('0-9A-Fa-f');
    final hexNumber =
        string('0x') &
        hexDigit.plus().flatten().map((hex) => int.parse(hex, radix: 16));

    // Decimal number
    final decimalNumber = digit().plus().flatten().map(int.parse);

    // Integer value (hex or decimal)
    final integerValue = hexNumber | decimalNumber;

    // Array element with optional comma
    final arrayElement = ws & integerValue & ws & char(',').optional();

    // Array content - collect all integer values
    final arrayContent =
        char('{') &
        ws &
        arrayElement.star().map<List<int>>((elements) {
          final values = <int>[];
          for (final element in elements) {
            if (element is List && element.length >= 2) {
              final value = element[1];
              if (value is int) {
                values.add(value);
              }
            }
          }
          return values;
        }) &
        ws &
        char('}');

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

    _parser = arrayDefinition.map((result) {
      final parts = result as List;

      // Extract type (skip const and whitespace)
      String type;
      int typeIndex = 2; // Start after const and ws
      type = parts[typeIndex] as String;

      // Extract name (skip type and whitespace)
      int nameIndex = typeIndex + 2; // Skip type and ws
      final name = parts[nameIndex] as String;

      // Extract size info (skip name and whitespace)
      int sizeIndex = nameIndex + 2; // Skip name and ws
      final sizeInfo = parts[sizeIndex];

      // Extract array content (skip size, ws, =, ws)
      int contentIndex = sizeIndex + 4; // Skip size, ws, =, ws
      final arrayContentResult = parts[contentIndex] as List;

      // Extract values from array content ['{', ws, values, ws, '}']
      final values = arrayContentResult[2] as List<int>;

      // Extract size from size info
      int? size;
      if (sizeInfo != null && sizeInfo is List && sizeInfo.length >= 3) {
        final sizeValue = sizeInfo[2];
        if (sizeValue is int) {
          size = sizeValue;
        }
      }

      return Graphics(
        //type: type,
        name: name,
        //size: size,
        data: values,
      );
    });
  }

  /// Parse a single integer array definition
  Graphics? parseArray(String input) {
    try {
      final result = _parser.parse(input);
      return result.value;
    } catch (e) {
      return null;
    }
  }

  /// Scan through the source line by line to find arrays
  List<Graphics> parseAllArrays(String cSource) {
    final arrays = <Graphics>[];
    final lines = cSource.split('\n');

    // Look for array declarations that might span multiple lines
    String currentBlock = '';
    bool inArrayDefinition = false;
    int braceCount = 0;

    for (String line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines and comments
      if (trimmedLine.isEmpty ||
          trimmedLine.startsWith('//') ||
          trimmedLine.startsWith('/*')) {
        continue;
      }

      // Check if this line starts an array definition
      if (!inArrayDefinition && _looksLikeArrayStart(trimmedLine)) {
        inArrayDefinition = true;
        currentBlock = line;
        braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
      } else if (inArrayDefinition) {
        currentBlock += ' $line';
        braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
      }

      // If we've closed all braces, try to parse the block
      if (inArrayDefinition && braceCount <= 0) {
        final parsed = parseArray(currentBlock);
        if (parsed != null) {
          arrays.add(parsed);
        }
        inArrayDefinition = false;
        currentBlock = '';
        braceCount = 0;
      }
    }

    return arrays;
  }

  bool _looksLikeArrayStart(String line) {
    final intTypes = ['unsigned char', 'uint8_t', 'UINT8'];

    return intTypes.any(
          (type) => line.toLowerCase().contains(type.toLowerCase()),
        ) &&
        line.contains('[') &&
        (line.contains('=') || line.contains('{'));
  }
}
