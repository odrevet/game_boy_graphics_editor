import 'dart:ui';

import 'colors.dart';

class AppState {
  int intensity;
  int metaTileIndexTile;
  int tileIndexBackground;
  bool tileMode; // edit tile or background
  bool showGridTile;
  bool floodMode;
  bool showGridBackground;
  List<int> tileBuffer; // copy / past tiles buffer
  List<Color> colorSet;

  AppState({
    this.intensity = 3,
    this.metaTileIndexTile = 0,
    this.tileIndexBackground = 0,
    this.tileMode = true,
    this.showGridTile = true,
    this.floodMode = false,
    this.showGridBackground = true,
    this.tileBuffer = const <int>[],
    this.colorSet = colorsPocket,
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
          List<Color>? colorSet}) =>
      AppState(
        intensity: intensity ?? this.intensity,
        metaTileIndexTile: metaTileIndexTile ?? this.metaTileIndexTile,
        tileIndexBackground: tileIndexBackground ?? this.tileIndexBackground,
        tileMode: tileMode ?? this.tileMode,
        showGridTile: showGridTile ?? this.showGridTile,
        floodMode: floodMode ?? this.floodMode,
        showGridBackground: showGridBackground ?? this.showGridBackground,
        tileBuffer: tileBuffer ?? this.tileBuffer,
        colorSet: colorSet ?? this.colorSet,
      );
}
