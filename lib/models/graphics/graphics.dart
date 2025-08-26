enum GraphicsType {
  undefined,
  tile,
  map,
  sprite,
}

class Graphics {
  String name;
  List<int> data;
  int height;
  int width;
  int tileOrigin;
  String? filepath;
  GraphicsType type;

  Graphics({
    required this.name,
    this.data = const [],
    this.width = 0,
    this.height = 0,
    this.filepath,
    this.tileOrigin = 0,
    this.type = GraphicsType.undefined,
  });
}
