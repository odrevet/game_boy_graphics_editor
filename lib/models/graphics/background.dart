import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

class Background extends Graphics {
  Background({height = 18, width = 20, name = "", this.tileOrigin = 0, fill, data})
      : super(
            width: width,
            height: height,
            data:
                data ?? List.filled(width * height, fill ?? 0, growable: true));

  int tileOrigin;

  copyWith({List<int>? data, int? width, int? height, int? tileOrigin}) => Background(
        data: data ?? [...this.data],
        width: width ?? this.width,
        height: height ?? this.height,
        tileOrigin: tileOrigin ?? this.tileOrigin,
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

  int getDataAt(int x, int y) {
    return data[(y * width) + x];
  }

  void setDataAt(int x, int y, int value) {
    data[(y * width) + x] = value;
  }

  flood(int intensity, int rowIndex, int colIndex,
      int targetColor) {
    if (getDataAt(rowIndex, colIndex) == targetColor) {
      setDataAt(rowIndex, colIndex, intensity);
      if (inbound(rowIndex, colIndex - 1)) {
        flood(intensity, rowIndex, colIndex - 1, targetColor);
      }
      if (inbound(rowIndex, colIndex + 1)) {
        flood(intensity, rowIndex, colIndex + 1, targetColor);
      }
      if (inbound(rowIndex - 1, colIndex)) {
        flood(intensity, rowIndex - 1, colIndex, targetColor);
      }
      if (inbound(rowIndex + 1, colIndex)) {
        flood(intensity, rowIndex + 1, colIndex, targetColor);
      }
    }
  }

  inbound(int rowIndex, int colIndex) =>
      rowIndex >= 0 && rowIndex < height && colIndex >= 0 && colIndex < width;
}
