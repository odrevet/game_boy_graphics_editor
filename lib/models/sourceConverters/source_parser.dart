import 'package:petitparser/petitparser.dart';

import '../graphics/graphics.dart';

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

    // Integer type patterns
    final integerType =
    string('unsigned char') |
    string('signed char') |
    string('unsigned short') |
    string('signed short') |
    string('unsigned int') |
    string('signed int') |
    string('unsigned long') |
    string('signed long') |
    string('uint8_t') |
    string('uint16_t') |
    string('uint32_t') |
    string('uint64_t') |
    string('int8_t') |
    string('int16_t') |
    string('int32_t') |
    string('int64_t') |
    string('UINT8') |
    string('UINT16') |
    string('UINT32') |
    string('UINT64') |
    string('INT8') |
    string('INT16') |
    string('INT32') |
    string('INT64') |
    string('char') |
    string('short') |
    string('int') |
    string('long');

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
        //type: type,
        name: name,
        //size: size,
        data: values,
        //startOffset: token.start,
        //endOffset: token.stop,
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
    int blockStartOffset = 0;
    int offset = 0;

    for (String line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty ||
          trimmedLine.startsWith('//') ||
          trimmedLine.startsWith('/*')) {
        offset += line.length + 1; // +1 for newline
        continue;
      }

      if (!inArrayDefinition && _looksLikeArrayStart(trimmedLine)) {
        inArrayDefinition = true;
        currentBlock = line;
        blockStartOffset = offset;
        braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
      } else if (inArrayDefinition) {
        currentBlock += '\n$line';
        braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
      }

      if (inArrayDefinition && braceCount <= 0) {
        final parsed = parseArray(currentBlock);
        if (parsed != null) {
          arrays.add(
            Graphics(
              name: parsed.name,
              //size: parsed.size,
              data: parsed.data,
              //startOffset: blockStartOffset,
              //endOffset: offset + line.length,
            ),
          );
        }
        inArrayDefinition = false;
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
      'char',
    ];

    return intTypes.any(
          (type) => line.toLowerCase().contains(type.toLowerCase()),
    ) &&
        line.contains('[') &&
        (line.contains('=') || line.contains('{'));
  }
}


/// Replace the array contents in the source with new values
/*String updateArrayValues(
    String source,
    Graphics array,
    List<int> newValues,
    ) {
  // Format the new array content
  final buffer = StringBuffer();
  buffer.writeln('{');

  for (int i = 0; i < newValues.length; i++) {
    final v = newValues[i];
    buffer.write('  0x${v.toRadixString(16).padLeft(2, '0')}');
    if (i != newValues.length - 1) buffer.write(',');
    if ((i + 1) % 8 == 0) buffer.writeln();
  }

  buffer.writeln();
  buffer.write('}');

  // Always recalc the size to match newValues.length
  final updatedSize = newValues.length;

  // Construct replacement string
  final declaration =
      '${array.type} ${array.name}[$updatedSize] = ${buffer.toString()};';

  // Replace in source
  return source.replaceRange(array.startOffset, array.endOffset, declaration);
}*/

