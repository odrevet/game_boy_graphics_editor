abstract class Graphics{
  List<int> data;
  String name;

  Graphics({required this.name, required this.data});

  void fromSource(String source);
  String toSource();
}