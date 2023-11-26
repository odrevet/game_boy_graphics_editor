import 'dart:convert';

import '../graphics/graphics.dart';

String hexToBinary(String value) {
  return int.parse(value).toRadixString(2).padLeft(8, "0");
}

String decToBinary(int value) {
  return value.toRadixString(2).padLeft(8, "0");
}

String binaryToHex(value) {
  return "0x${int.parse(value, radix: 2).toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

String decimalToHex(int value, {bool prefix = false}) {
  return "${prefix ? '0x' : ''}${value.toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

int binaryToDec(String value) {
  return int.parse(value, radix: 2);
}

List<int> hexToIntList(String hexString) {
  List<int> result = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String hexPair = hexString.substring(i, i + 2);
    int decimalValue = int.parse(hexPair, radix: 16);
    result.add(decimalValue);
  }
  return result;
}

String formatHexPairs(String hexString) {
  if (hexString.length.isOdd) {
    hexString = "${hexString}0";
  }

  return hexString
      .replaceAllMapped(RegExp(r".."), (match) => '0x${match.group(0)} ')
      .trimRight()
      .replaceAll(' ', ', ');
}

// Elements read from source
class GraphicElement {
  String name;
  List<int> values;

  GraphicElement({required this.name, required this.values});
}

abstract class SourceConverter {
  String formatOutput(input) {
    return input.asMap().entries.map((entry) {
      int idx = entry.key;
      String val = entry.value;
      return idx % 8 == 0 ? "\n  $val" : val;
    }).join(", ");
  }

  String toHeader(Graphics graphics, String name);

  String toSource(Graphics graphics, String name);

  String formatSource(String source) {
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(source);
    return lines.join();
  }

  List<GraphicElement> readGraphicElementsFromSource(String source) {
    var arrayElements = <GraphicElement>[];

    RegExp regExp = RegExp(
        r"(?:unsigned\s+char|uint8_t|UINT8)\s+(\w+)\[(?:\d+)?\]\s*=\s*\{(.*?)};");
    for (Match match in regExp.allMatches(source)) {
      // remove trailing comma if any
      String matchedValues = match.group(2)!.replaceFirst(RegExp(r',\s*$'), '');

      List<int> values = List<int>.from(
          matchedValues.split(',').map((value) => int.parse(value)).toList());
      arrayElements.add(GraphicElement(name: match.group(1)!, values: values));
    }

    return arrayElements;
  }
}
