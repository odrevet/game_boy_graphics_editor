import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/dot_matrix.dart';

import '../../colors.dart';
import '../../meta_tile.dart';
import '../../tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final int selectedTileIndex;

  late final List<int> indexTiles;

  MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.selectedTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    if (metaTile.width == 8 && metaTile.height == 8) {
      indexTiles = <int>[0];
    } else if (metaTile.width == 8 && metaTile.height == 16) {
      indexTiles = <int>[0, 1];
    } else if (metaTile.width == 16 && metaTile.height == 16) {
      indexTiles = <int>[0, 2, 1, 3];
    } else if (metaTile.width == 32 && metaTile.height == 32) {
      indexTiles = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      indexTiles = <int>[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: metaTile.width ~/ Tile.size,
      children: <Widget>[
        for (var indexTile in indexTiles)
          DotMatrix(
            onTap: onTap,
            onTapParam: indexTile,
            pixels: metaTile.tileList[selectedTileIndex].data
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
