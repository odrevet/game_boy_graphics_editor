import 'dart:ui';

import 'colors.dart';

class AppState {
  List<int> tileData;
  int tileHeight;
  int tileWidth;

  int intensity;
  int tileIndexTile;
  int tileIndexBackground;
  bool tileMode; // edit tile or background
  bool showGridTile;
  bool floodMode;
  bool showGridBackground;
  List<int> tileBuffer; // copy / past tiles buffer
  List<Color> colorSet;

  AppState({
    required this.tileData,
    this.tileHeight = 8,
    this.tileWidth = 8,
    this.intensity = 3,
    this.tileIndexTile = 0,
    this.tileIndexBackground = 0,
    this.tileMode = true,
    this.showGridTile = true,
    this.floodMode = false,
    this.showGridBackground = true,
    this.tileBuffer = const <int>[],
    this.colorSet = colorsDMG,
  });

  copyWith(
          {int? intensity,
          int? metaTileIndexTile,
          int? tileIndexBackground,
          bool? tileMode,
          bool? showGridTile,
          bool? floodMode,
          bool? showGridBackground,
          List<int>? tileBuffer,
          List<int>? tileData,
          int? tileWidth,
          int? tileHeight,
          List<Color>? colorSet}) =>
      AppState(
        intensity: intensity ?? this.intensity,
        tileIndexTile: metaTileIndexTile ?? this.tileIndexTile,
        tileIndexBackground: tileIndexBackground ?? this.tileIndexBackground,
        tileMode: tileMode ?? this.tileMode,
        showGridTile: showGridTile ?? this.showGridTile,
        floodMode: floodMode ?? this.floodMode,
        showGridBackground: showGridBackground ?? this.showGridBackground,
        tileBuffer: tileBuffer ?? this.tileBuffer,
        tileData: tileData ?? this.tileData,
        tileWidth: tileWidth ?? this.tileWidth,
        tileHeight: tileHeight ?? this.tileHeight,
        colorSet: colorSet ?? this.colorSet,
      );

  int get tileSize => tileWidth * tileHeight;

  List<int> getTile(int index) {
    return tileData.getRange(tileSize * index, tileSize * index + tileSize).toList();
  }

  List<int> getCurrentTile() => getTile(tileIndexTile);
}
