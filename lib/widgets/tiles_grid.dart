import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';

import '../colors.dart';
import '../tiles.dart';

class TilesGrid extends StatelessWidget {
  final Tiles tiles;
  final Function setPixel;
  final bool showGrid;
  final int selectedTileIndex;

  const TilesGrid(
      {required this.tiles,
      required this.setPixel,
      required this.showGrid,
      required this.selectedTileIndex,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> indexTiles;

    // There probably is a more dynamic way to do this
    if (tiles.width == 8 && tiles.height == 8) {
      indexTiles = <int>[0];
    } else if (tiles.width == 8 && tiles.height == 16) {
      indexTiles = <int>[0, 1];
    } else if (tiles.width == 16 && tiles.height == 16) {
      indexTiles = <int>[0, 2, 1, 3];
    } else if (tiles.width == 32 && tiles.height == 32) {
      indexTiles = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      indexTiles = [];
    }

    var children = <Widget>[];

    for (var indexTile in indexTiles) {
      children.add(DotMatrix(
        onTap: (indexPixel) => {setPixel(indexPixel, indexTile)},
        pixels: tiles
            .getData(selectedTileIndex + indexTile)
            .map((e) => colors[e])
            .toList(),
        showGrid: showGrid,
        width: 8,
        height: 8,
      ));
    }

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(8),
      crossAxisCount: tiles.width ~/ 8,
      children: children,
    );
  }
}
