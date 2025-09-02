import '../graphics/graphics.dart';
import 'package:petitparser/petitparser.dart';

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
      final parts = token.value as List;

      String type = parts[2] as String;
      String name = parts[4] as String;
      final sizeInfo = parts[6];
      final arrayContentResult = parts[10] as List;

      final elementsResult = arrayContentResult[2] as List;
      final values = <int>[];

      for (final element in elementsResult) {
        if (element is List && element.length >= 2) {
          final value = element[1];
          if (value is int) values.add(value);
        }
      }

      int? size;
      if (sizeInfo != null && sizeInfo is List && sizeInfo.length >= 3) {
        final sizeValue = sizeInfo[2];
        if (sizeValue is int) size = sizeValue;
      }

      return Graphics(
        name: name,
        data: values,
      );
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
      if (inArrayDefinition && foundEquals && foundOpenBrace && braceCount <= 0) {
        int arrayEndOffset = offset + line.length; // Track where the array definition ends

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
    final intTypes = [
      'uint8_t',
      'unsigned char',
      'char',
      'UINT8'
    ];

    // Check if line contains an integer type and has array brackets
    return intTypes.any(
          (type) => line.toLowerCase().contains(type.toLowerCase()),
    ) && line.contains('[');
  }
}
