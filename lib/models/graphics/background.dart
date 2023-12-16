import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

class Background extends Graphics {
  Background({height = 18, width = 20, name = "", fill, data})
      : super(
            width: width,
            height: height,
            data:
                data ?? List.filled(width * height, fill ?? 0, growable: true));

  int tileOrigin = 0;

  copyWith({List<int>? data, int? width, int? height}) => Background(
        data: data ?? [...this.data],
        width: width ?? this.width,
        height: height ?? this.height,
      );

  void insertCol(int at, int fill) {
    width += 1;
    for (int index = at; index < data.length; index += width) {
      data.insert(index, fill);
    }
  }

  void deleteCol(int at) {
    width -= 1;
    for (int index = at; index < data.length; index += width) {
      data.removeAt(index);
    }
  }

  void insertRow(int at, int fill) {
    height += 1;
    for (int index = 0; index < width; index += 1) {
      data.insert(at * width, fill);
    }
  }

  void deleteRow(int at) {
    height -= 1;
    for (int index = 0; index < width; index += 1) {
      data.removeAt(at * width);
    }
  }

  int getDataAt(int x, int y){
    return data[(y * width) + x];
  }

  void setDataAt(int x, int y, int value){
    data[(y * width) + x] = value;
  }
}
