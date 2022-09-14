import 'package:replay_bloc/replay_bloc.dart';

import '../models/graphics/background.dart';

class BackgroundCubit extends ReplayCubit<Background> {
  BackgroundCubit() : super(Background(height: 20, width: 18));

  setData(List<int> data) {
    emit(state.copyWith(data: data));
  }

  setWidth(int width) {
    emit(state.copyWith(width: width));
  }

  setHeight(int height) {
    emit(state.copyWith(height: height));
  }

  void setTileIndex(int rowIndex, int colIndex, int tileIndex) {
    List<int> tileData = [...state.data];
    tileData[colIndex * state.width + rowIndex] = tileIndex;
    emit(state.copyWith(data: tileData));
  }

  void insertCol(int at, int fill) {
    var background = state.copyWith();
    background.insertCol(at, fill);
    emit(background);
  }

  void deleteCol(int at) {
    var background = state.copyWith();
    background.deleteCol(at);
    emit(background);
  }

  void insertRow(int at, int fill) {
    var background = state.copyWith();
    background.insertRow(at, fill);
    emit(background);
  }

  void deleteRow(int at) {
    var background = state.copyWith();
    background.deleteRow(at);
    emit(background);
  }
}
