import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/colors.dart';

import '../models/states/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit()
      : super(
    AppState(
      intensity: 3,
      tileIndexTile: 0,
      zoomTile: 0.6,
      zoomBackground: 0.6,
      showExportPreviewTile: true,
      showExportPreviewBackground: true,
      currentView: ViewType.editor,
    ),
  );

  // View Management Methods
  void setCurrentView(ViewType newView) {
    emit(state.copyWith(currentView: newView));
  }

  void navigateToEditor() => setCurrentView(ViewType.editor);

  void navigateToMemoryManager() => setCurrentView(ViewType.memoryManager);

  void navigateToSettings() => setCurrentView(ViewType.settings);

  // View State Helpers
  bool get isEditorView => state.currentView == ViewType.editor;

  bool get isMemoryManagerView => state.currentView == ViewType.memoryManager;

  bool get isSettingsView => state.currentView == ViewType.settings;

  String get currentViewTitle {
    switch (state.currentView) {
      case ViewType.editor:
        return 'Graphics Editor';
      case ViewType.memoryManager:
        return 'Memory Manager';
      case ViewType.settings:
        return 'Settings';
    }
  }

  // Original methods
  void setIntensity(int intensity) =>
      emit(state.copyWith(intensity: intensity));

  void setTileName(String tileName) => emit(state.copyWith(tileName: tileName));

  void setBackgroundName(String backgroundName) =>
      emit(state.copyWith(backgroundName: backgroundName));

  void setSelectedTileIndex(index) =>
      emit(state.copyWith(tileIndexTile: index));

  void setTileBuffer(tileBuffer) =>
      emit(state.copyWith(tileBuffer: tileBuffer));

  void setGbdkPath(gbdkPath) => emit(state.copyWith(gbdkPath: gbdkPath));

  void setGbdkPathValid() {
    bool isValid;
    try {
      var result = Process.runSync('${state.gbdkPath}/gbcompress', []);
      emit(state.copyWith(gbdkPathValid: result.exitCode > 0));
      isValid = result.exitCode > 0;
    } catch (e) {
      isValid = false;
    }

    emit(state.copyWith(gbdkPathValid: isValid));
  }

  void setDrawModeTile(DrawMode drawMode) =>
      emit(state.copyWith(drawModeTile: drawMode));

  void setDrawModeBackground(DrawMode drawMode) =>
      emit(state.copyWith(drawModeBackground: drawMode));

  void toggleGridTile() =>
      emit(state.copyWith(showGridTile: !state.showGridTile));

  void toggleColorSet() =>
      emit(
        state.copyWith(
          colorSet: state.colorSet == colorsPocket ? colorsDMG : colorsPocket,
        ),
      );

  void toggleGridBackground() =>
      emit(state.copyWith(showGridBackground: !state.showGridBackground));

  toggleDisplayExportPreviewBackground() {
    emit(
      state.copyWith(
        showExportPreviewBackground: !state.showExportPreviewBackground,
      ),
    );
  }

  toggleDisplayExportPreviewTile() {
    emit(state.copyWith(showExportPreviewTile: !state.showExportPreviewTile));
  }

  void increaseZoomTile() {
    emit(state.copyWith(zoomTile: state.zoomTile + 0.1));
  }

  void decreaseZoomTile() {
    emit(state.copyWith(zoomTile: state.zoomTile - 0.1));
  }

  void increaseZoomBackground() {
    emit(state.copyWith(zoomBackground: state.zoomBackground + 0.2));
  }

  void decreaseZoomBackground() {
    emit(state.copyWith(zoomBackground: state.zoomBackground - 0.2));
  }

  void toggleLockScrollBackground() {
    emit(state.copyWith(lockScrollBackground: !state.lockScrollBackground));
  }
}
