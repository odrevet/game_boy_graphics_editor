import 'package:petitparser/petitparser.dart';

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
  int startOffset;
  int endOffset;

  Graphics({
    required this.name,
    this.data = const [],
    this.width = 0,
    this.height = 0,
    this.filepath,
    this.tileOrigin = 0,
    this.type = GraphicsType.undefined,
    this.startOffset = 0,
    this.endOffset = 0,
  });

}