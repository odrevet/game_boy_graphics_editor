import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/graphics/graphics.dart';
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
}
