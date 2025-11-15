import 'package:replay_bloc/replay_bloc.dart';

import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';

class BackgroundCubit extends ReplayCubit<Background> {
  BackgroundCubit()
    : super(Background(height: 18, width: 20, name: "background"));

  // Load background data from a Graphics object
  void loadFromGraphics(Graphics graphics) {
    emit(graphics as Background);
  }

  setData(List<int> data) {
    emit(state.copyWith(data: data));
  }

  setName(String name) {
    emit(state.copyWith(name: name));
  }

  setWidth(int width) {
    Background background = state.copyWith();

    if (background.width < width) {
      while (background.width < width) {
        background.insertCol(background.data.length % background.width, 0);
      }
    } else {
      while (background.width > width) {
        background.deleteCol(background.data.length % background.width);
      }
    }

    emit(background);
  }

  setHeight(int height) {
    Background background = state.copyWith();

    if (background.height < height) {
      while (background.height < height) {
        background.insertRow(background.data.length % background.height, 0);
      }
    } else {
      while (background.height > height) {
        background.deleteRow(background.data.length % background.height);
      }
    }

    emit(background);
  }

  void setTileIndex(int rowIndex, int colIndex, int tileIndex) {
    Background background = state.copyWith();
    background.setDataAt(rowIndex, colIndex, tileIndex);
    emit(background);
  }

  void line(int i, int xFrom, int yFrom, int xTo, int yTo) {
    Background background = state.copyWith();
    background.line(i, xFrom, yFrom, xTo, yTo);
    emit(background);
  }

  void rectangle(int i, int xFrom, int yFrom, int xTo, int yTo) {
    Background background = state.copyWith();
    background.rectangle(i, xFrom, yFrom, xTo, yTo);
    emit(background);
  }

  void fill(intensity, rowIndex, colIndex, targetColor) {
    Background background = state.copyWith();
    background.fill(intensity, rowIndex, colIndex, targetColor);
    emit(background);
  }

  void insertCol(int at, int fill) {
    Background background = state.copyWith();
    background.insertCol(at, fill);
    emit(background);
  }

  void deleteCol(int at) {
    Background background = state.copyWith();
    background.deleteCol(at);
    emit(background);
  }

  void insertRow(int at, int fill) {
    Background background = state.copyWith();
    background.insertRow(at, fill);
    emit(background);
  }

  void deleteRow(int at) {
    Background background = state.copyWith();
    background.deleteRow(at);
    emit(background);
  }

  setOrigin(int tileOrigin) {
    Background background = state.copyWith(tileOrigin: tileOrigin);
    emit(background);
  }

  transpose() {
    Background background = state.copyWith(
      width: state.height,
      height: state.width,
    );

    for (int rowIndex = 0; rowIndex < background.height; rowIndex++) {
      for (int colIndex = 0; colIndex < background.width; colIndex++) {
        int value = state.getDataAt(rowIndex, colIndex);
        background.setDataAt(colIndex, rowIndex, value);
      }
    }

    emit(background);
  }
}
