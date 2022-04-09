import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gbdk_graphic_editor/meta_tile.dart';
import 'package:gbdk_graphic_editor/tile.dart';

class MetaTileCubit extends Cubit<MetaTile> {
  MetaTileCubit() : super(MetaTile(tileList: [])..tileList.add(Tile()));

  setPixel(int rowIndex, int colIndex, metaTileIndex, intensity) {
    var metaTile = state.copyWith();
    metaTile.setPixel(rowIndex, colIndex, metaTileIndex, intensity);
    emit(metaTile);
  }

  List<int> _shift(List<int> list, int v) {
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  void rightShift(int selectedMetaTileIndexTile) {
    var metaTile = state.copyWith();

    for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
      var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow);
      row.replaceRange(0, row.length, _shift(row, -1));
      metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
      emit(metaTile);
    }
  }

  void leftShift(int selectedMetaTileIndexTile) {
    var metaTile = state.copyWith();

    for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
      var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow);
      row.replaceRange(0, row.length, _shift(row, 1));
      metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
      emit(metaTile);
    }
  }

  void upShift(int selectedMetaTileIndexTile) {
    var metaTile = state.copyWith();
    var rowTemp = metaTile.getRow(selectedMetaTileIndexTile, 0);

    for (int indexRow = 0; indexRow < metaTile.height - 1; indexRow++) {
      var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow + 1);
      metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
    }

    metaTile.setRow(selectedMetaTileIndexTile, metaTile.height - 1, rowTemp);

    emit(metaTile);
  }

  void downShift(int selectedMetaTileIndexTile) {
    var metaTile = state.copyWith();
    var rowTemp =
        metaTile.getRow(selectedMetaTileIndexTile, metaTile.height - 1);

    for (int indexRow = metaTile.height - 1; indexRow > 0; indexRow--) {
      var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow - 1);
      metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
    }

    metaTile.setRow(selectedMetaTileIndexTile, 0, rowTemp);
    emit(metaTile);
  }

  _copyMetaTile(MetaTile metaTile) => metaTile.copyWith(
      tileList: List.generate(metaTile.nbTilePerMetaTile(), (_) => Tile()));

  _setMetaTileData(
      MetaTile metaTileTemp, MetaTile metaTile, int selectedMetaTileIndexTile) {
    for (int rowIndex = 0; rowIndex < metaTile.width; rowIndex++) {
      for (int colIndex = 0; colIndex < metaTile.height; colIndex++) {
        int intensity = metaTileTemp.getPixel(rowIndex, colIndex, 0);
        metaTile.setPixel(
            rowIndex, colIndex, selectedMetaTileIndexTile, intensity);
      }
    }
  }

  flipHorizontal(int selectedMetaTileIndexTile) {
    var metaTile = _copyMetaTile(state);

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
            rowIndex, state.width - 1 - colIndex, selectedMetaTileIndexTile);
        metaTile.setPixel(rowIndex, colIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTile, state, selectedMetaTileIndexTile);
    emit(metaTile);
  }

  flipVertical(int selectedMetaTileIndexTile) {
    var metaTile = _copyMetaTile(state);

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
            state.width - 1 - colIndex, rowIndex, selectedMetaTileIndexTile);
        metaTile.setPixel(colIndex, rowIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTile, state, selectedMetaTileIndexTile);
    emit(metaTile);
  }

  void rotateRight(int selectedMetaTileIndexTile) {
    var metaTile = _copyMetaTile(state);

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
            rowIndex, state.width - 1 - colIndex, selectedMetaTileIndexTile);
        metaTile.setPixel(colIndex, rowIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTile, state, selectedMetaTileIndexTile);
    emit(metaTile);
  }

  void rotateLeft(int selectedMetaTileIndexTile) {
    var metaTile = _copyMetaTile(state);

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
            state.width - 1 - colIndex, rowIndex, selectedMetaTileIndexTile);
        metaTile.setPixel(rowIndex, colIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTile, state, selectedMetaTileIndexTile);
    emit(metaTile);
  }

  void setDimensions(width, height) {
    var metaTile =
        state.copyWith(tileList: state.tileList, width: width, height: height);
    int numberOfTilesNecessary =
        metaTile.nbTilePerMetaTile() - metaTile.tileList.length;

    for (int i = 0; i < numberOfTilesNecessary; i++) {
      metaTile.tileList.add(Tile());
    }

    emit(metaTile);
  }

  void copy(int index, tileBuffer) {
    var metaTile = state.copyWith();

    tileBuffer.clear();
    for (var i = index; i < index + metaTile.nbTilePerMetaTile(); i++) {
      tileBuffer.addAll(metaTile.tileList[i].data);
    }

    emit(metaTile);
  }

  void paste(int index, tileBuffer) {
    var metaTile = state.copyWith();

    for (var i = 0; i < tileBuffer.length; i++) {
      int tileIndex =
          i ~/ Tile.pixelPerTile + index * metaTile.nbTilePerMetaTile();
      metaTile.tileList[tileIndex].data[i % Tile.pixelPerTile] = tileBuffer[i];
    }

    emit(metaTile);
  }

  void insert(int index) => emit(state.copyWith(
      tileList: state.tileList
        ..insertAll(index * state.nbTilePerMetaTile(),
            List<Tile>.generate(state.nbTilePerMetaTile(), (_) => Tile()))));

  void remove(int index) => emit(state.copyWith(
      tileList: state.tileList
        ..removeRange(index * state.nbTilePerMetaTile(),
            index * state.nbTilePerMetaTile() + state.nbTilePerMetaTile())));
}
