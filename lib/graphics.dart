abstract class Graphics {
  List<int> data;
  String name;

  Graphics({required this.name, required this.data});

  void fromSource(String source);

  String toSource();

  List? parseArray(source) {
    RegExp regExp = RegExp(r"unsigned char (\w+)\[\] =\n\{\n([\s\S]*)};");
    var matches = regExp.allMatches(source);

    var name = "";
    var values = "";

    for (Match match in matches) {
      name = match.group(1)!;
      values = match.group(2)!;
    }

    if (name != "" && values.isNotEmpty) {
      return [name, values];
    }
    return null;
  }
}
