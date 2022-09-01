import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/dot_matrix.dart';

import '../../models/meta_tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final List<int> tileData;
  final bool showGrid;
  final int metaTileIndex;
  final List<Color> colorSet;

  const MetaTileDisplay(
      {required this.tileData,
      required this.showGrid,
      required this.metaTileIndex,
      required this.colorSet,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DotMatrix(
        pixels: tileData
            .map((e) => colorSet[e])
            .toList(),
        showGrid: showGrid);
  }
}
