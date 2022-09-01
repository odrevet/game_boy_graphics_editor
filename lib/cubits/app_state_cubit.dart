import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/colors.dart';

import '../models/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState(intensity: 3, metaTileIndexTile: 0, tileData: List.generate(64, (index) => 0)));

  void setIntensity(intensity) => emit(state.copyWith(intensity: intensity));

  void setSelectedTileIndex(index) => emit(state.copyWith(metaTileIndexTile: index));

  void toggleTileMode() => emit(state.copyWith(tileMode: !state.tileMode));

  void toggleFloodMode() => emit(state.copyWith(floodMode: !state.floodMode));

  void setTileIndexBackground(index) => emit(state.copyWith(tileIndexBackground: index));

  void toggleGridTile() => emit(state.copyWith(showGridTile: !state.showGridTile));

  void toggleColorSet() => emit(state.copyWith(colorSet: colorsPocket));

  void toggleGridBackground() =>
      emit(state.copyWith(showGridBackground: !state.showGridBackground));

  void setPixel(rowIndex, colIndex, intensity) {
    List<int> tileData = [...state.tileData];
    tileData[colIndex * state.tileWidth + rowIndex] = intensity;
    emit(state.copyWith(tileData: tileData));
  }
}
