import 'dart:convert';

import '../convert.dart';
import '../graphics.dart';

class GraphicElement {
  String name;
  String values;

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
}
