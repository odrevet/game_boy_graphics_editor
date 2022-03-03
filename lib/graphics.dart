abstract class Graphics {
  List<int> data;
  String name;

  Graphics({required this.name, required this.data});

  void fromSource(String source);

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
