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

  Map<String, int> readDefinesFromSource(String source) {
    Map<String, int> defines = {};
    RegExp regExp = RegExp(r"#define (\w+) (\d+)");
    for (Match match in regExp.allMatches(source)) {
      defines[match.group(1)!] = int.parse(match.group(2)!);
    }
    return defines;
  }
}
