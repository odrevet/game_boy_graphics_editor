abstract class Graphics {
  int height;
  int width;
  String name;

  Graphics(
      {required this.name,
      required this.width,
      required this.height});

  bool fromSource(String source);

  String toHeader();

  String toSource();

  String formatOutput(input) {
    return input.asMap().entries.map((entry) {
      int idx = entry.key;
      String val = entry.value;
      return idx % 8 == 0 ? "\n  $val" : val;
    }).join(", ");
  }

  String? parseArray(source) {
    RegExp regExp = RegExp(r"unsigned\s+char\s+(\w+)\[\]\s*=\s*\{(.*)};");
    var matches = regExp.allMatches(source);

    String values = "";

    for (Match match in matches) {
      name = match.group(1)!;
      values = match.group(2)!;
    }

    return values;
  }
}
