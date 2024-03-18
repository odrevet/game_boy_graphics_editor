import 'dart:ui';

import 'colors.dart';

class AppState {
  int intensity;
  int tileIndexTile;
  int tileIndexBackground;
  bool tileMode; // edit tile or background
  double zoomTile;
  double zoomBackground;
  bool lockScrollBackground;
  bool showGridTile;
  bool floodMode;
  bool showGridBackground;
  bool showExportPreviewBackground;
  bool showExportPreviewTile;
  List<int> tileBuffer; // copy / past tiles buffer
  List<Color> colorSet;
  String tileName;
  String backgroundName;
  String gbdkPath;
  bool gbdkPathValid;

  AppState({
    this.intensity = 3,
    this.tileIndexTile = 0,
    this.tileIndexBackground = 0,
    this.tileMode = true,
    this.zoomTile = 0.6,
    this.zoomBackground = 0.6,
    this.lockScrollBackground = false,
    this.showGridTile = true,
    this.tileName = "Tile",
    this.backgroundName = "Background",
    this.floodMode = false,
    this.showGridBackground = true,
    this.showExportPreviewBackground = false,
    this.showExportPreviewTile = false,
    this.tileBuffer = const <int>[],
    this.colorSet = colorsDMG,
    this.gbdkPath = '',
    this.gbdkPathValid = false,
  });

  copyWith(
          {int? intensity,
          int? tileIndexTile,
          int? tileIndexBackground,
          bool? tileMode,
          double? zoomTile,
          double? zoomBackground,
          bool? lockScrollBackground,
          bool? showGridTile,
          String? tileName,
          String? backgroundName,
          String? gbdkPath,
          bool? gbdkPathValid,
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
        zoomTile: zoomTile ?? this.zoomTile,
        zoomBackground: zoomBackground ?? this.zoomBackground,
        lockScrollBackground: lockScrollBackground ?? this.lockScrollBackground,
        showGridTile: showGridTile ?? this.showGridTile,
        gbdkPath: gbdkPath ?? this.gbdkPath,
        gbdkPathValid: gbdkPathValid ?? this.gbdkPathValid,
        tileName: tileName ?? this.tileName,
        backgroundName: backgroundName ?? this.backgroundName,
        floodMode: floodMode ?? this.floodMode,
        showGridBackground: showGridBackground ?? this.showGridBackground,
        showExportPreviewBackground:
            showExportPreviewBackground ?? this.showExportPreviewBackground,
        showExportPreviewTile:
            showExportPreviewTile ?? this.showExportPreviewTile,
        tileBuffer: tileBuffer ?? [...this.tileBuffer],
        colorSet: colorSet ?? this.colorSet,
      );
}
