import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/colors.dart';

import '../models/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit({bool tileMode = true})
      : super(AppState(
            intensity: 3,
            tileIndexTile: 0,
            zoomTile: 0.6,
            showExportPreviewTile: true,
            showExportPreviewBackground: true,
            tileMode: tileMode));

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

  void toggleTileMode() => emit(state.copyWith(tileMode: !state.tileMode));

  void setMode(bool isTile) => emit(state.copyWith(tileMode: isTile));

  void toggleFloodMode() => emit(state.copyWith(floodMode: !state.floodMode));

  void setTileIndexBackground(index) =>
      emit(state.copyWith(tileIndexBackground: index));

  void toggleGridTile() =>
      emit(state.copyWith(showGridTile: !state.showGridTile));

  void toggleColorSet() => emit(state.copyWith(
      colorSet: state.colorSet == colorsPocket ? colorsDMG : colorsPocket));

  void toggleGridBackground() =>
      emit(state.copyWith(showGridBackground: !state.showGridBackground));

  toggleDisplayExportPreviewBackground() {
    emit(state.copyWith(
        showExportPreviewBackground: !state.showExportPreviewBackground));
  }

  toggleDisplayExportPreviewTile() {
    emit(state.copyWith(showExportPreviewTile: !state.showExportPreviewTile));
  }

  void increaseZoomTile(){
    emit(state.copyWith(zoomTile: state.zoomTile + 0.1));
  }

  void decreaseZoomTile(){
    emit(state.copyWith(zoomTile: state.zoomTile - 0.1));
  }
}
