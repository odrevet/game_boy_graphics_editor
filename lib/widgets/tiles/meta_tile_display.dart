import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/dot_matrix.dart';

import '../../colors.dart';
import '../../meta_tile.dart';
import '../../tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final int metaTileIndex;

  late final List<int> pattern;

  MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    pattern = metaTile.getPattern();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: metaTile.width ~/ Tile.size,
      children: <Widget>[
        for (int i = 0; i < metaTile.nbTilePerMetaTile(); i++)
          DotMatrix(
            onTap: onTap,
            onTapParam:
                metaTileIndex * metaTile.nbTilePerMetaTile() + pattern[i],
            pixels: metaTile
                .tileList[
                    metaTileIndex * metaTile.nbTilePerMetaTile() + pattern[i]]
                .data
                .map((e) => colors[e])
                .toList(),
            showGrid: showGrid,
            width: Tile.size,
            height: Tile.size,
          )
      ],
    );
  }
}
