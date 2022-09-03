import 'package:game_boy_graphics_editor/models/meta_tile.dart';
import 'package:replay_bloc/replay_bloc.dart';

class MetaTileCubit extends ReplayCubit<MetaTile> {
  MetaTileCubit() : super(MetaTile(tileData: List.generate(64, (index) => 0)));

  List<int> _shift(List<int> list, int v) {
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  flood(int rowIndex, int colIndex, int metaTileIndex, int intensity, int targetColor) =>
      emit(state.copyWith()..flood(metaTileIndex, intensity, rowIndex, colIndex, targetColor));

  void setPixel(int rowIndex, int colIndex, int tileIndexTile, int intensity) {
    List<int> tileData = [...state.tileData];
    tileData[(colIndex * state.width + rowIndex) + state.tileSize * tileIndexTile] = intensity;
    emit(state.copyWith(tileData: tileData));
  }

  void setDimensions(int width, int height) => emit(state.copyWith(
      width: width, height: height, tileData: List.generate(width * height, (index) => 0)));

  void addTile(int index) {
    List<int> tileData = [...state.tileData];
    var newTile = List.generate(state.width * state.height, (index) => 0);
    tileData.insertAll((index + 1) * state.tileSize, newTile);
    emit(state.copyWith(tileData: tileData));
  }

  void removeTile(int index) {
    List<int> tileData = [...state.tileData];
    tileData.removeRange((index) * state.tileSize, index * state.tileSize + state.tileSize);
    emit(state.copyWith(tileData: tileData));
  }

  void rightShift(int index) {}

  void leftShift(int index) {}

  void upShift(int index) {}

  void downShift(int index) {}

  flipHorizontal(int index) {
  }

  flipVertical(int index) {}

  void rotateRight(int index) {}

  void rotateLeft(int index) {}

  void paste(int index, tileBuffer) {}
}
