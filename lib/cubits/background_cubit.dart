import 'package:game_boy_graphics_editor/models/meta_tile.dart';
import 'package:replay_bloc/replay_bloc.dart';

import '../models/background.dart';

class BackgroundCubit extends ReplayCubit<Background> {
  BackgroundCubit() : super(Background(height: 20, width: 18));

  void insertCol(int at, int fill) {
    //.insertCol(hoverTileIndex % widget.background.width, widget.selectedTileIndex);
    emit(state.copyWith());
  }

  void deleteCol(int at) {
    emit(state.copyWith());
  }

  void insertRow(int at, int fill) {
    emit(state.copyWith());
  }

  void deleteRow(int at) {
    emit(state.copyWith());
  }
}
