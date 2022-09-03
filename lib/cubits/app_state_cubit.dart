import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/colors.dart';

import '../models/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit()
      : super(AppState(
      intensity: 3, tileIndexTile: 0, tileData: List.generate(64, (index) => 0)));

  void setIntensity(intensity) => emit(state.copyWith(intensity: intensity));

  void setSelectedTileIndex(index) => emit(state.copyWith(metaTileIndexTile: index));

  void toggleTileMode() => emit(state.copyWith(tileMode: !state.tileMode));

  void toggleFloodMode() => emit(state.copyWith(floodMode: !state.floodMode));

  void setTileIndexBackground(index) => emit(state.copyWith(tileIndexBackground: index));

  void toggleGridTile() => emit(state.copyWith(showGridTile: !state.showGridTile));

  void toggleColorSet() => emit(state.copyWith(colorSet: colorsPocket));

  void toggleGridBackground() =>
      emit(state.copyWith(showGridBackground: !state.showGridBackground));

  void setPixel(rowIndex, colIndex) {
    List<int> tileData = [...state.tileData];
    tileData[(colIndex * state.tileWidth + rowIndex) + state.tileSize * state.tileIndexTile] = state.intensity;
    emit(state.copyWith(tileData: tileData));
  }

  void setDimensions(int width, int height) =>
      emit(state.copyWith(
          tileWidth: width,
          tileHeight: height,
          tileData: List.generate(width * height, (index) => 0)));

  void addTile() {
    var newTile = List.generate(state.tileWidth * state.tileHeight, (index) => 0);
    emit(state.copyWith(tileData: state.tileData + newTile));
  }

  void removeTile() =>
      emit(state.copyWith(tileData: state.tileData
        ..removeRange(
            state.tileData.length - state.tileWidth * state.tileHeight, state.tileData.length)));

}
