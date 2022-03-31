import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/dot_matrix.dart';

import '../../colors.dart';
import '../../meta_tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final MetaTile metaTile;
  final bool showGrid;
  final int metaTileIndex;

  const MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
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
                  .tileList[metaTileIndex * metaTile.nbTilePerMetaTile() +
                      metaTile.getPattern()[i]]
                  .data
                  .map((e) => colors[e])
                  .toList(),
              showGrid: showGrid)
      ],
    );
  }
}
