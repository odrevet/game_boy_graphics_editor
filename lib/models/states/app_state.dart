import '../colors.dart';

enum DrawMode { single, fill, line, rectangle }

enum ViewType { editor, memoryManager, settings, import }

class AppState {
  int intensity;

  int tileIndexTile;

  double zoomTile;
  double zoomBackground;

  bool lockScrollBackground;

  bool showGridTile;
  bool showGridBackground;

  DrawMode drawModeTile;
  DrawMode drawModeBackground;

  int? drawFromTile;
  int? drawFromBackground;

  bool showExportPreviewBackground;
  bool showExportPreviewTile;

  List<int> tileBuffer; // copy / past tiles buffer
  List<int> colorSet;
  String tileName;
  String backgroundName;
  String gbdkPath;
  bool gbdkPathValid;

  // View management
  ViewType currentView;

  AppState({
    this.intensity = 3,
    this.tileIndexTile = 0,
    this.zoomTile = 0.4,
    this.zoomBackground = 0.4,
    this.lockScrollBackground = false,
    this.showGridTile = true,
    this.tileName = "Tile",
    this.backgroundName = "Background",
    this.drawModeTile = DrawMode.single,
    this.drawModeBackground = DrawMode.single,
    this.drawFromTile,
    this.drawFromBackground,
    this.showGridBackground = true,
    this.showExportPreviewBackground = false,
    this.showExportPreviewTile = false,
    this.tileBuffer = const <int>[],
    this.colorSet = colorsDMG,
    this.gbdkPath = '',
    this.gbdkPathValid = false,
    this.currentView = ViewType.editor,
  });

  copyWith({
    int? intensity,
    int? tileIndexTile,
    double? zoomTile,
    double? zoomBackground,
    bool? lockScrollBackground,
    bool? showGridTile,
    String? tileName,
    String? backgroundName,
    String? gbdkPath,
    bool? gbdkPathValid,
    DrawMode? drawModeTile,
    DrawMode? drawModeBackground,
    bool? showGridBackground,
    bool? showExportPreviewBackground,
    bool? showExportPreviewTile,
    List<int>? tileBuffer,
    List<int>? colorSet,
    ViewType? currentView,
  }) => AppState(
    intensity: intensity ?? this.intensity,
    tileIndexTile: tileIndexTile ?? this.tileIndexTile,
    zoomTile: zoomTile ?? this.zoomTile,
    zoomBackground: zoomBackground ?? this.zoomBackground,
    lockScrollBackground: lockScrollBackground ?? this.lockScrollBackground,
    showGridTile: showGridTile ?? this.showGridTile,
    gbdkPath: gbdkPath ?? this.gbdkPath,
    gbdkPathValid: gbdkPathValid ?? this.gbdkPathValid,
    tileName: tileName ?? this.tileName,
    backgroundName: backgroundName ?? this.backgroundName,
    drawModeTile: drawModeTile ?? this.drawModeTile,
    drawModeBackground: drawModeBackground ?? this.drawModeBackground,
    showGridBackground: showGridBackground ?? this.showGridBackground,
    showExportPreviewBackground:
        showExportPreviewBackground ?? this.showExportPreviewBackground,
    showExportPreviewTile: showExportPreviewTile ?? this.showExportPreviewTile,
    tileBuffer: tileBuffer ?? [...this.tileBuffer],
    colorSet: colorSet ?? this.colorSet,
    currentView: currentView ?? this.currentView,
  );
}
