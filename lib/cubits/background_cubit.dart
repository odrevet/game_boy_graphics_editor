import 'package:replay_bloc/replay_bloc.dart';

import '../models/background.dart';

class BackgroundCubit extends ReplayCubit<Background> {
  BackgroundCubit() : super(Background(height: 20, width: 18));

  void insertCol(int at, int fill) {
    var background = state.copyWith();
    background.insertCol(at, fill);
    emit(background);
  }

  void deleteCol(int at) {
    var background = state.copyWith();
    background.deleteCol(at);
    emit(background);
  }

  void insertRow(int at, int fill) {
    var background = state.copyWith();
    background.insertRow(at, fill);
    emit(background);
  }

  void deleteRow(int at) {
    var background = state.copyWith();
    background.deleteRow(at);
    emit(background);
  }
}
