import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';

import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/states/graphics_state.dart';

class GraphicsCubit extends Cubit<GraphicsState> {
  GraphicsCubit() : super(const GraphicsState());

  // Add a single graphic
  void addGraphic(Graphics graphic) {
    final updatedGraphics = List<Graphics>.from(state.graphics)..add(graphic);
    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Add multiple graphics
  void addGraphics(List<Graphics> graphics) {
    final updatedGraphics = List<Graphics>.from(state.graphics)
      ..addAll(graphics);
    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Remove a graphic by index
  void removeGraphicAt(int index) {
    if (index < 0 || index >= state.graphics.length) {
      emit(state.copyWith(error: 'Invalid index: $index'));
      return;
    }

    final updatedGraphics = List<Graphics>.from(state.graphics)
      ..removeAt(index);
    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Remove a specific graphic
  void removeGraphic(Graphics graphic) {
    final updatedGraphics = List<Graphics>.from(state.graphics)
      ..remove(graphic);
    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Update a graphic at specific index
  void updateGraphicAt(int index, Graphics newGraphic) {
    if (index < 0 || index >= state.graphics.length) {
      emit(state.copyWith(error: 'Invalid index: $index'));
      return;
    }

    final updatedGraphics = List<Graphics>.from(state.graphics);
    updatedGraphics[index] = newGraphic;
    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Commit background data to graphics - this is the key synchronization method
  // TODO find and update the original source graphic (using equatable ?)
  void commitBackgroundToGraphics(Background background, {int? targetIndex}) {
    final graphicsFromBackground = Graphics(
      height: background.height,
      width: background.width,
      data: List<int>.from(background.data),
      tileOrigin: background.tileOrigin,
      name: background.name,
    );

    if (targetIndex != null) {
      // Update existing graphic at specified index
      updateGraphicAt(targetIndex, graphicsFromBackground);
    } else {
      // Add as new graphic
      addGraphic(graphicsFromBackground);
    }
  }

  int? findGraphicByNameAndOrigin(String name, int tileOrigin) {
    for (int i = 0; i < state.graphics.length; i++) {
      final g = state.graphics[i];
      if (g.name == name && g.tileOrigin == tileOrigin) {
        return i;
      }
    }
    return null;
  }


  // Commit background data to graphics - this is the key synchronization method
  void commitMetaTileToGraphics(Graphics metaTile, String sourceName, int tileOrigin) {
    List<int> data = GBDKTileConverter().toSourceData(metaTile);
    // this is a WIP, currently add a new graphic
    int? targetIndex = findGraphicByNameAndOrigin(sourceName, tileOrigin);

    final graphics = Graphics(
      height: 8, //metaTile.height,
      width: 8, //metaTile.width,
      data: data,
      tileOrigin: metaTile.tileOrigin,
      name: metaTile.name,
    );

    if (targetIndex != null) {
      // Update existing graphic at specified index
      updateGraphicAt(targetIndex, graphics);
    } else {
      // Add as new graphic
      addGraphic(graphics);
    }
  }

  // Load background data from graphics for editing
  Background? getBackgroundFromGraphics(int graphicsIndex) {
    final graphic = getGraphicAt(graphicsIndex);
    if (graphic == null || graphic.data == null) return null;

    return Background(
      height: graphic.height ?? 18,
      width: graphic.width ?? 20,
      data: List<int>.from(graphic.data!),
      tileOrigin: graphic.tileOrigin ?? 0,
    );
  }

  // Clear all graphics
  void clearGraphics() {
    emit(state.copyWith(graphics: [], error: null));
  }

  // Get graphic by index
  Graphics? getGraphicAt(int index) {
    if (index < 0 || index >= state.graphics.length) {
      emit(state.copyWith(error: 'Invalid index: $index'));
      return null;
    }
    return state.graphics[index];
  }

  // Get graphics count
  int get graphicsCount => state.graphics.length;

  // Check if collection is empty
  bool get isEmpty => state.graphics.isEmpty;

  // Reorder graphics
  void reorderGraphics(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.graphics.length ||
        newIndex < 0 ||
        newIndex >= state.graphics.length) {
      emit(state.copyWith(error: 'Invalid reorder indices'));
      return;
    }

    final updatedGraphics = List<Graphics>.from(state.graphics);
    final graphic = updatedGraphics.removeAt(oldIndex);
    updatedGraphics.insert(newIndex, graphic);

    emit(state.copyWith(graphics: updatedGraphics, error: null));
  }

  // Find graphics that match background criteria (helper method)
  List<int> findBackgroundGraphics() {
    List<int> indices = [];
    for (int i = 0; i < state.graphics.length; i++) {
      final graphic = state.graphics[i];
      // Add logic here to identify which graphics are backgrounds
      // This could be based on naming convention, type property, etc.
      if (graphic is Background == true) {
        // Assuming you have this property
        indices.add(i);
      }
    }
    return indices;
  }
}
