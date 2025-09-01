import 'dart:convert';

import '../graphics/graphics.dart';

abstract class SourceConverter {
  String formatOutput(input) {
    return input
        .asMap()
        .entries
        .map((entry) {
          int idx = entry.key;
          String val = entry.value;
          return idx % 8 == 0 ? "\n  $val" : val;
        })
        .join(", ");
  }

  String toHeader(Graphics graphics, String name);

  String toSource(Graphics graphics, String name);

  String formatSource(String source) {
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(source);
    return lines.join();
  }

  List<Graphics> readGraphicsFromSource(String source) {
    var graphics = <Graphics>[];

    RegExp regExp = RegExp(
      r"(?:unsigned\s+char|uint8_t|UINT8)\s+(\w+)\[(?:\d+)?\]\s*=\s*\{(.*?)};",
    );
    for (Match match in regExp.allMatches(source)) {
      // remove trailing comma if any
      String matchedValues = match.group(2)!.replaceFirst(RegExp(r',\s*$'), '');

      List<int> values = List<int>.from(
        matchedValues.split(',').map((value) => int.parse(value)).toList(),
      );
      graphics.add(Graphics(name: match.group(1)!, data: values));
    }

    return graphics;
  }

  Map<String, int> readDefinesFromSource(String source) {
    Map<String, int> defines = {};
    RegExp regExp = RegExp(r"#define (\w+) (\d+)");
    for (Match match in regExp.allMatches(source)) {
      defines[match.group(1)!] = int.parse(match.group(2)!);
    }
    return defines;
  }
}
