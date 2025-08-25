import 'package:equatable/equatable.dart';

import '../graphics/graphics.dart';

class GraphicsState extends Equatable {
  final List<Graphics> graphics;
  final bool isLoading;
  final String? error;

  const GraphicsState({
    this.graphics = const [],
    this.isLoading = false,
    this.error,
  });

  GraphicsState copyWith({
    List<Graphics>? graphics,
    bool? isLoading,
    String? error,
  }) {
    return GraphicsState(
      graphics: graphics ?? this.graphics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [graphics, isLoading, error];
}
