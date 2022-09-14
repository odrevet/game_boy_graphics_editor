import 'dart:ui';

import 'colors.dart';

class AppState {
  int intensity;
  int tileIndexTile;
  int tileIndexBackground;
  bool tileMode; // edit tile or background
  bool showGridTile;
  bool floodMode;
  bool showGridBackground;
  bool showExportPreviewBackground;
  bool showExportPreviewTile;
  List<int> tileBuffer; // copy / past tiles buffer
  List<Color> colorSet;
  String tileName;
  String backgroundName;

  AppState({
    this.intensity = 3,
    this.tileIndexTile = 0,
    this.tileIndexBackground = 0,
    this.tileMode = true,
    this.showGridTile = true,
    this.tileName = "Tile",
    this.backgroundName = "Background",
    this.floodMode = false,
    this.showGridBackground = true,
    this.showExportPreviewBackground = false,
    this.showExportPreviewTile = false,
    this.tileBuffer = const <int>[],
    this.colorSet = colorsDMG,
  });

  copyWith(
          {int? intensity,
          int? tileIndexTile,
          int? tileIndexBackground,
          bool? tileMode,
          bool? showGridTile,
          String? tileName,
          String? backgroundName,
          bool? floodMode,
          bool? showGridBackground,
          bool? showExportPreviewBackground,
          bool? showExportPreviewTile,
          List<int>? tileBuffer,
          List<Color>? colorSet}) =>
      AppState(
        intensity: intensity ?? this.intensity,
        tileIndexTile: tileIndexTile ?? this.tileIndexTile,
        tileIndexBackground: tileIndexBackground ?? this.tileIndexBackground,
        tileMode: tileMode ?? this.tileMode,
        showGridTile: showGridTile ?? this.showGridTile,
        tileName: tileName ?? this.tileName,
        backgroundName: backgroundName ?? this.backgroundName,
        floodMode: floodMode ?? this.floodMode,
        showGridBackground: showGridBackground ?? this.showGridBackground,
        showExportPreviewBackground:
            showExportPreviewBackground ?? this.showExportPreviewBackground,
        showExportPreviewTile: showExportPreviewTile ?? this.showExportPreviewTile,
        tileBuffer: tileBuffer ?? [...this.tileBuffer],
        colorSet: colorSet ?? this.colorSet,
      );
}
