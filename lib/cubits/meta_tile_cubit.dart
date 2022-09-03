import 'package:game_boy_graphics_editor/models/meta_tile.dart';
import 'package:replay_bloc/replay_bloc.dart';

class MetaTileCubit extends ReplayCubit<MetaTile> {
  MetaTileCubit() : super(MetaTile(tileData: List.generate(64, (index) => 0)));

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

  void rightShift(int selectedMetaTileIndexTile) {}

  void leftShift(int selectedMetaTileIndexTile) {}

  void upShift(int selectedMetaTileIndexTile) {}

  void downShift(int selectedMetaTileIndexTile) {}

  flipHorizontal(int selectedMetaTileIndexTile) {}

  flipVertical(int selectedMetaTileIndexTile) {}

  void rotateRight(int selectedMetaTileIndexTile) {}

  void rotateLeft(int selectedMetaTileIndexTile) {}

  void paste(int index, tileBuffer) {}

  void insert(int index) {}

  void remove(int index) => emit(state.copyWith());
}
