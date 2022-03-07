abstract class Graphics {
  int height;
  int width;
  List<int> data;
  String name;

  Graphics({required this.name, required this.data, required this.width, required this.height});

  void fromSource(String source);

  String toHeader();

  String toSource();

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
