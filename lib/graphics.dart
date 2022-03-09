abstract class Graphics {
  int height;
  int width;
  List<int> data;
  String name;

  Graphics(
      {required this.name,
      required this.data,
      required this.width,
      required this.height});

  void fromSource(String source);

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
    RegExp regExp = RegExp(r"unsigned char (\w+)\[\] =\{(.*)};");
    var matches = regExp.allMatches(source);

    String values = "";

    for (Match match in matches) {
      name = match.group(1)!;
      values = match.group(2)!;
    }

    return values;
  }
}
