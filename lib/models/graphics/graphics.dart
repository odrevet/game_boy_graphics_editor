class Graphics {
  String name;
  List<int> data;
  int height;
  int width;
  String? filepath;
  int tileOrigin;

  Graphics({
    required this.name,
    this.data = const [],
    this.width = 0,
    this.height = 0,
    this.filepath,
    this.tileOrigin = 0,
  });
}
