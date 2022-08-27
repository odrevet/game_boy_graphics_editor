import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/dot_matrix.dart';

import '../../models/meta_tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final MetaTile metaTile;
  final bool showGrid;
  final int metaTileIndex;
  final List<Color> colorSet;

  const MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
      required this.colorSet,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: metaTile.nbTilePerRow(),
      children: <Widget>[
        for (int i = 0; i < metaTile.nbTilePerMetaTile(); i++)
          DotMatrix(
              pixels: metaTile
                  .tileList[metaTileIndex * metaTile.nbTilePerMetaTile() + metaTile.getPattern()[i]]
                  .data
                  .map((e) => colorSet[e])
                  .toList(),
              showGrid: showGrid)
      ],
    );
  }
}
