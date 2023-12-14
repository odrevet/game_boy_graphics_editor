import 'package:replay_bloc/replay_bloc.dart';

import '../models/graphics/background.dart';

class BackgroundCubit extends ReplayCubit<Background> {
  BackgroundCubit() : super(Background(height: 18, width: 20));

  setData(List<int> data) {
    emit(state.copyWith(data: data));
  }

  setWidth(int width) {
    Background background = state.copyWith(
        width: width, data: List.filled(width * state.height, 0));
    emit(background);
  }

  setHeight(int height) {
    Background background = state.copyWith(
        height: height, data: List.filled(height * state.width, 0));
    emit(background);
  }

  void setTileIndex(int rowIndex, int colIndex, int tileIndex) {
    List<int> tileData = [...state.data];
    tileData[colIndex * state.width + rowIndex] = tileIndex;
    emit(state.copyWith(data: tileData));
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

  setOrigin(int origin) {
    Background background = state.copyWith();
    background.origin = origin;
    emit(background);
  }

  transpose() {
    Background background = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int value = state.getDataAt(rowIndex, colIndex);
        background.setDataAt(colIndex, rowIndex, value);
      }
    }

    emit(background);
  }
}
