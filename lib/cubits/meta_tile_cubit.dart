import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:replay_bloc/replay_bloc.dart';

import '../models/sourceConverters/gbdk_tile_converter.dart';

class MetaTileCubit extends ReplayCubit<MetaTile> {
  MetaTileCubit() : super(MetaTile(height: 8, width: 8));

  // Replace TileInfo list with MetaTile list
  List<MetaTile?> _metaTilesInfo = [];

  setData(List<int> data) {
    _metaTilesInfo.clear();
    emit(state.copyWith(data: data));
  }

  setDataAtIndex(int at, List<int> data) {
    emit(
      state.copyWith(
        data: [...state.data]..setAll(at * state.width * state.height, data),
      ),
    );
  }

  List<int> _shift(List<int> list, int v) {
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  fill(
    int rowIndex,
    int colIndex,
    int metaTileIndex,
    int intensity,
    int targetColor,
  ) => emit(
    state.copyWith()
      ..fill(metaTileIndex, intensity, rowIndex, colIndex, targetColor),
  );

  void setPixel(int rowIndex, int colIndex, int tileIndex, int intensity) {
    List<int> tileData = [...state.data];
    tileData[(colIndex * state.width + rowIndex) + state.nbPixel * tileIndex] =
        intensity;
    emit(state.copyWith(data: tileData));
  }

  void setDimensions(int width, int height) =>
      emit(state.copyWith(width: width, height: height));

  void addTile(int index) {
    List<int> tileData = [...state.data];
    var newTile = List.generate(state.width * state.height, (index) => 0);
    tileData.insertAll((index + 1) * state.nbPixel, newTile);

    // Update meta tiles info list - add null for empty tile
    _metaTilesInfo.insert(index + 1, null);

    emit(state.copyWith(data: tileData));
  }

  void removeTile(int tileIndex) {
    List<int> tileData = [...state.data];
    tileData.removeRange(
      (tileIndex) * state.nbPixel,
      tileIndex * state.nbPixel + state.nbPixel,
    );

    // Update meta tiles info list
    if (tileIndex < _metaTilesInfo.length) {
      _metaTilesInfo.removeAt(tileIndex);
    }

    emit(state.copyWith(data: tileData));
  }

  /// Clear all pixels in a tile (set them to 0)
  void clearTile(int tileIndex) {
    final currentState = state;
    final tileSize = currentState.height * currentState.width;
    final totalTiles = currentState.data.length ~/ tileSize;

    if (tileIndex >= 0 && tileIndex < totalTiles) {
      List<int> newData = List.from(currentState.data);
      final startIndex = tileIndex * tileSize;

      // Clear all pixels in the tile (set to 0)
      for (int i = 0; i < tileSize; i++) {
        if (startIndex + i < newData.length) {
          newData[startIndex + i] = 0;
        }
      }

      // Clear the meta tile info for this position
      if (tileIndex < _metaTilesInfo.length) {
        _metaTilesInfo[tileIndex] = null;
      }

      emit(currentState.copyWith(data: newData));
    }
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
        int intensity = state.getPixel(
          rowIndex,
          state.width - 1 - colIndex,
          tileIndex,
        );
        metaTile.setPixel(rowIndex, colIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  flipVertical(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
          state.width - 1 - colIndex,
          rowIndex,
          tileIndex,
        );
        metaTile.setPixel(colIndex, rowIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  void rotateRight(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
          rowIndex,
          state.width - 1 - colIndex,
          tileIndex,
        );
        metaTile.setPixel(colIndex, rowIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  void rotateLeft(int tileIndex) {
    var metaTile = state.copyWith();

    for (int rowIndex = 0; rowIndex < state.height; rowIndex++) {
      for (int colIndex = 0; colIndex < state.width; colIndex++) {
        int intensity = state.getPixel(
          state.width - 1 - colIndex,
          rowIndex,
          tileIndex,
        );
        metaTile.setPixel(rowIndex, colIndex, tileIndex, intensity);
      }
    }

    emit(metaTile);
  }

  int count() => state.data.length ~/ (state.height * state.width);

  int maxTileIndex() => state.data.length ~/ (state.height * state.width);

  void line(int metaTileIndex, int intensity, int xFrom, int yFrom, xTo, yTo) {
    MetaTile metaTile = state.copyWith();
    metaTile.line(metaTileIndex, intensity, xFrom, yFrom, xTo, yTo);
    emit(metaTile);
  }

  void rectangle(
    int metaTileIndex,
    int intensity,
    int xFrom,
    int yFrom,
    int xTo,
    int yTo,
  ) {
    MetaTile metaTile = state.copyWith();
    metaTile.rectangle(metaTileIndex, intensity, xFrom, yFrom, xTo, yTo);
    emit(metaTile);
  }

  /// Add tiles from graphics data at specified origin
  void addTileAtOrigin(MetaTile metaTile, int tileOrigin) {
    final currentState = state;
    final tileSize = currentState.height * currentState.width;
    final numTiles = metaTile.data.length ~/ tileSize;

    // Ensure our meta tiles info list is large enough
    while (_metaTilesInfo.length < currentState.data.length ~/ tileSize) {
      _metaTilesInfo.add(null);
    }

    // Extend data if necessary to accommodate new tiles
    List<int> newData = List.from(currentState.data);
    final requiredSize = (tileOrigin + numTiles) * tileSize;

    while (newData.length < requiredSize) {
      // Add empty tiles (filled with 0s)
      newData.addAll(List.filled(tileSize, 0));
      _metaTilesInfo.add(null);
    }

    // Copy the new tile data starting at the specified origin
    for (int i = 0; i < numTiles; i++) {
      final tileIndex = tileOrigin + i;
      final dataStartIndex = tileIndex * tileSize;
      final sourceStartIndex = i * tileSize;

      // Copy tile data
      for (int j = 0; j < tileSize; j++) {
        if (dataStartIndex + j < newData.length &&
            sourceStartIndex + j < metaTile.data.length) {
          newData[dataStartIndex + j] = metaTile.data[sourceStartIndex + j];
        }
      }

      // Store the source MetaTile info with the tile origin
      _metaTilesInfo[tileIndex] = metaTile.copyWith(tileOrigin: tileOrigin);
    }

    emit(
      MetaTile(
        height: currentState.height,
        width: currentState.width,
        data: newData,
      ),
    );
  }

  // Extract tiles for a specific source to commit back to graphics
  List<int> extractSourceTileData(String sourceName, int tileOrigin) {
    final tileSize = state.height * state.width;
    List<int> sourceTiles = [];

    // Find all tiles that belong to this source
    for (int i = 0; i < _metaTilesInfo.length; i++) {
      final metaTileInfo = _metaTilesInfo[i];
      if (metaTileInfo != null &&
          metaTileInfo.name == sourceName &&
          metaTileInfo.tileOrigin == tileOrigin) {
        final startIndex = i * tileSize;
        final endIndex = startIndex + tileSize;

        if (endIndex <= state.data.length) {
          sourceTiles.addAll(state.data.sublist(startIndex, endIndex));
        }
      }
    }

    // Convert back to source format
    return GBDKTileConverter().reorderFromCanvasToSource(
      MetaTile(height: state.height, width: state.width, data: sourceTiles),
    );
  }

  /// Get meta tiles info list
  List<MetaTile?> getMetaTilesInfo() {
    final tileSize = state.height * state.width;
    final totalTiles = state.data.length ~/ tileSize;

    // Ensure info list matches current tile count
    while (_metaTilesInfo.length < totalTiles) {
      _metaTilesInfo.add(null);
    }

    return List.from(_metaTilesInfo);
  }

  /// Remove tile at specific index (clear tile data)
  void removeTileAt(int index) {
    final currentState = state;
    final tileSize = currentState.height * currentState.width;
    final totalTiles = currentState.data.length ~/ tileSize;

    if (index >= 0 && index < totalTiles) {
      // Clear tile data (fill with zeros)
      List<int> newData = List.from(currentState.data);
      final startIndex = index * tileSize;

      for (int i = 0; i < tileSize; i++) {
        if (startIndex + i < newData.length) {
          newData[startIndex + i] = 0;
        }
      }

      // Clear meta tile info
      if (index < _metaTilesInfo.length) {
        _metaTilesInfo[index] = null;
      }

      emit(
        MetaTile(
          height: currentState.height,
          width: currentState.width,
          data: newData,
        ),
      );
    }
  }

  /// Get tiles loaded at specific origin
  List<int> getTilesAtOrigin(int origin) {
    return _metaTilesInfo
        .asMap()
        .entries
        .where(
          (entry) => entry.value != null && entry.value!.tileOrigin == origin,
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all unique origins
  List<int> getUniqueOrigins() {
    return _metaTilesInfo
        .where((info) => info != null)
        .map((info) => info!.tileOrigin)
        .toSet()
        .toList()
      ..sort();
  }

  /// Check if a tile at index is unmapped (null or has no name)
  bool isTileUnmapped(int index) {
    if (index >= _metaTilesInfo.length) return true;
    final info = _metaTilesInfo[index];
    return info == null || info.name.isEmpty;
  }

  /// Get the source name for a tile at index
  String? getTileSourceName(int index) {
    if (index >= _metaTilesInfo.length) return null;
    return _metaTilesInfo[index]?.name;
  }

  /// Get the tile origin for a tile at index
  int? getTileOrigin(int index) {
    if (index >= _metaTilesInfo.length) return null;
    return _metaTilesInfo[index]?.tileOrigin;
  }

  /// Get the source info for a tile at index
  dynamic getTileSourceInfo(int index) {
    if (index >= _metaTilesInfo.length) return null;
    return _metaTilesInfo[index]?.sourceInfo;
  }
}
