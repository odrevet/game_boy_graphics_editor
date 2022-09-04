import 'package:game_boy_graphics_editor/models/graphics.dart';

import 'convert.dart';
import 'meta_tile.dart';

class Background extends Graphics {
  Background({required data, height = 0, width = 0, name = "", int fill = 0})
      : super(data: data, width: width, height: height) {
    data = List<int>.filled(height * width, fill, growable: true);
  }

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
}
