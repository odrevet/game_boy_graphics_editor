import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

class Background extends Graphics {
  Background({
    super.height = 18,
    super.width = 20,
    super.name = "",
    super.tileOrigin = 0,
    fill,
    data,
  }) : super(
    data: data ?? List.filled(width * height, fill ?? 0, growable: true),
  );

  copyWith({List<int>? data, int? width, int? height, int? tileOrigin}) =>
      Background(
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

  fill(int intensity, int rowIndex, int colIndex, int targetColor) {
    if (getDataAt(rowIndex, colIndex) == targetColor) {
      setDataAt(rowIndex, colIndex, intensity);
      if (inbound(rowIndex, colIndex - 1)) {
        fill(intensity, rowIndex, colIndex - 1, targetColor);
      }
      if (inbound(rowIndex, colIndex + 1)) {
        fill(intensity, rowIndex, colIndex + 1, targetColor);
      }
      if (inbound(rowIndex - 1, colIndex)) {
        fill(intensity, rowIndex - 1, colIndex, targetColor);
      }
      if (inbound(rowIndex + 1, colIndex)) {
        fill(intensity, rowIndex + 1, colIndex, targetColor);
      }
    }
  }

  inbound(int rowIndex, int colIndex) {
    return rowIndex > 0 &&
        rowIndex < height &&
        colIndex > 0 &&
        colIndex < width;
  }

  void line(int i, int xFrom, int yFrom, int xTo, int yTo) {
    int dx = (xTo - xFrom).abs(),
        sx = xFrom < xTo ? 1 : -1;
    int dy = (yTo - yFrom).abs(),
        sy = yFrom < yTo ? 1 : -1;
    double err = ((dx > dy ? dx : -dy) / 2);
    double e2;

    for (;;) {
      setDataAt(xFrom, yFrom, i);
      if (xFrom == xTo && yFrom == yTo) break;
      e2 = err;
      if (e2 > -dx) {
        err -= dy;
        xFrom += sx;
      }
      if (e2 < dy) {
        err += dx;
        yFrom += sy;
      }
    }
  }

  void rectangleBorder(int i, int xFrom, int yFrom, int xTo, int yTo) {
    for (int x = xFrom; x <= xTo; x++) {
      setDataAt(x, yFrom, i);
      setDataAt(x, yTo, i);
    }
    for (int y = yFrom; y <= yTo; y++) {
      setDataAt(xFrom, y, i);
      setDataAt(xTo, y, i);
    }
  }

  void rectangle(int i, int xFrom, int yFrom, int xTo, int yTo) {
    int startX = xFrom < xTo ? xFrom : xTo;
    int endX = xFrom < xTo ? xTo : xFrom;
    int startY = yFrom < yTo ? yFrom : yTo;
    int endY = yFrom < yTo ? yTo : yFrom;

    for (int y = startY; y <= endY; y++) {
      for (int x = startX; x <= endX; x++) {
        setDataAt(x, y, i);
      }
    }
  }
}
