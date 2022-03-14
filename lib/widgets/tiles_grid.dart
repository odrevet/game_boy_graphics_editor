import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';

import '../colors.dart';
import '../tiles.dart';

class TilesGrid extends StatelessWidget {
  final Tiles tiles;
  final Function? onTap;
  final bool showGrid;
  final int selectedTileIndex;

  late final List<int> indexTiles;

  TilesGrid(
      {required this.tiles,
      required this.showGrid,
      required this.selectedTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    if (tiles.width == 8 && tiles.height == 8) {
      indexTiles = <int>[0];
    } else if (tiles.width == 8 && tiles.height == 16) {
      indexTiles = <int>[0, 1];
    } else if (tiles.width == 16 && tiles.height == 16) {
      indexTiles = <int>[0, 2, 1, 3];
    } else if (tiles.width == 32 && tiles.height == 32) {
      indexTiles = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      indexTiles = <int>[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: tiles.width ~/ Tiles.size,
      children: <Widget>[
        for (var indexTile in indexTiles)
          DotMatrix(
            onTap: onTap,
            onTapParam: indexTile,
            pixels: tiles
                .getAtIndex(selectedTileIndex *
                        (tiles.height ~/ Tiles.size) *
                        (tiles.width ~/ Tiles.size) +
                    indexTile)
                .map((e) => colors[e])
                .toList(),
            showGrid: showGrid,
            width: Tiles.size,
            height: Tiles.size,
          )
      ],
    );
  }
}
