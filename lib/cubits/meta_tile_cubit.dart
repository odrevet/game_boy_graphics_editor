import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:replay_bloc/replay_bloc.dart';

import '../models/sourceConverters/source_converter.dart';

class MetaTileCubit extends ReplayCubit<MetaTile> {
  MetaTileCubit() : super(MetaTile(height: 8, width: 8));

  List<int> _shift(List<int> list, int v) {
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  flood(int rowIndex, int colIndex, int metaTileIndex, int intensity, int targetColor) =>
      emit(state.copyWith()..flood(metaTileIndex, intensity, rowIndex, colIndex, targetColor));

  void setPixel(int rowIndex, int colIndex, int tileIndexTile, int intensity) {
    List<int> tileData = [...state.data];
    tileData[(colIndex * state.width + rowIndex) + state.nbPixel * tileIndexTile] = intensity;
    emit(state.copyWith(data: tileData));
  }

  void setDimensions(int width, int height) => emit(state.copyWith(
      width: width, height: height, data: List.generate(width * height, (index) => 0)));

  void addTile(int index) {
    List<int> tileData = [...state.data];
    var newTile = List.generate(state.width * state.height, (index) => 0);
    tileData.insertAll((index + 1) * state.nbPixel, newTile);
    emit(state.copyWith(data: tileData));
  }

  void removeTile(int tileIndex) {
    List<int> tileData = [...state.data];
    tileData.removeRange((tileIndex) * state.nbPixel, tileIndex * state.nbPixel + state.nbPixel);
    emit(state.copyWith(data: tileData));
  }

  void rightShift(int tileIndex, int index) {
    var metaTile = state.copyWith();

    for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
      var row = metaTile.getRow(tileIndex, indexRow);
      row.replaceRange(0, row.length, _shift(row, -1));
      metaTile.setRow(tileIndex, indexRow, row);
    }

    emit(metaTile);
  }

  void leftShift(int tileIndex, int index) {
    var metaTile = state.copyWith();

    for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
      var row = metaTile.getRow(tileIndex, indexRow);
      row.replaceRange(0, row.length, _shift(row, 1));
      metaTile.setRow(tileIndex, indexRow, row);
    }

    emit(metaTile);
  }

  void upShift(int tileIndex, int index) {
    var metaTile = state.copyWith();
    var rowTemp = metaTile.getRow(tileIndex, 0);

    for (int indexRow = 0; indexRow < metaTile.height - 1; indexRow++) {
      var row = metaTile.getRow(tileIndex, indexRow + 1);
      metaTile.setRow(tileIndex, indexRow, row);
    }

    metaTile.setRow(tileIndex, metaTile.height - 1, rowTemp);
    emit(metaTile);
  }

  void downShift(int tileIndex, int index) {
    var metaTile = state.copyWith();
    var rowTemp = metaTile.getRow(tileIndex, metaTile.height - 1);

    for (int indexRow = metaTile.height - 1; indexRow > 0; indexRow--) {
      var row = metaTile.getRow(tileIndex, indexRow - 1);
      metaTile.setRow(tileIndex, indexRow, row);
    }

    metaTile.setRow(tileIndex, 0, rowTemp);
    emit(metaTile);
  }

  flipHorizontal(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(rowIndex, state.width - 1 - colIndex, tileIndex);
        metaTile.setPixel(rowIndex, colIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  flipVertical(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(state.width - 1 - colIndex, rowIndex, tileIndex);
        metaTile.setPixel(colIndex, rowIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  void rotateRight(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(rowIndex, state.width - 1 - colIndex, tileIndex);
        metaTile.setPixel(colIndex, rowIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  void rotateLeft(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(state.width - 1 - colIndex, rowIndex, tileIndex);
        metaTile.setPixel(rowIndex, colIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  void paste(int tileIndex, tileBuffer) {}

  List<int> getPattern(int width, int height) {
    var pattern = <int>[];

    if (width == 8 && height == 8) {
      pattern = <int>[0];
    } else if (width == 8 && height == 16) {
      pattern = <int>[0, 1];
    } else if (width == 16 && height == 16) {
      pattern = <int>[0, 2, 1, 3];
    } else if (width == 32 && height == 32) {
      pattern = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      throw ('Unknown meta tile size');
    }

    return pattern;
  }

  setData(List<String> values) {
    var data = <int>[];

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index]);
      var hi = toBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < MetaTile.tileSize; index++) {
        combined += hi[index] + lo[index];
      }

      for (var indexBis = 0; indexBis < MetaTile.tileSize * 2; indexBis += 2) {
        data.add(int.parse(combined[indexBis] + combined[indexBis + 1], radix: 2));
      }
    }

    // reorder tile data

    // if data is too small, resize it to fit the metaTile dimensions
    if(data.length < state.width * state.height){
      data.addAll(List.filled(state.width * state.height - data.length, 0));
    }

    List<int> reorderedData = List.filled(data.length, 0);
    var pattern = getPattern(state.width, state.height);
    int nbTilePerRow = (state.width ~/ MetaTile.tileSize);
    int nbTilePerMetaTile =(state.width * state.height) ~/ MetaTile.nbPixelPerTile;

    for (int tileIndex = 0; tileIndex < data.length ~/ MetaTile.nbPixelPerTile; tileIndex++) {
      int patternIndex = pattern[tileIndex % pattern.length];

      int metaTileIndex = tileIndex ~/ nbTilePerMetaTile;
      int pixel = patternIndex * MetaTile.nbPixelPerTile;
      for (int col = 0; col < MetaTile.tileSize; col++) {
        int start = pixel + col * MetaTile.tileSize + (metaTileIndex * state.width * state.height);
        int end = start + MetaTile.tileSize;
        var row = data.sublist(start, end);
        int reorderedPixel = ((tileIndex % nbTilePerRow) * MetaTile.tileSize) +
            (tileIndex ~/ nbTilePerRow).floor() * MetaTile.nbPixelPerTile * nbTilePerRow +
            col * state.width;
        reorderedData.setRange(reorderedPixel, reorderedPixel + MetaTile.tileSize, row);
      }
    }

    emit(state.copyWith(data: reorderedData));
  }
}
