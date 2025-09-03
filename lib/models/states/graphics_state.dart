import 'package:equatable/equatable.dart';

import '../graphics/graphics.dart';

class GraphicsState extends Equatable {
  final List<Graphics> graphics;

  const GraphicsState({this.graphics = const []});

  GraphicsState copyWith({
    List<Graphics>? graphics,
    bool? isLoading,
    String? error,
  }) {
    return GraphicsState(graphics: graphics ?? this.graphics);
  }

  @override
  List<Object?> get props => [graphics];
}
