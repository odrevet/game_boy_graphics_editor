import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../colors.dart';
import '../tiles.dart';
import 'background_widget.dart';
import 'graphics_data_display.dart';

class TilesEditor extends StatelessWidget {
  final Background preview;
  final Tiles tiles;
  final Function setTilesIndex;
  final Function setPixel;
  final bool showGrid;
  final int selectedTileIndex;

  const TilesEditor(
      {Key? key,
      required this.preview,
      required this.tiles,
      required this.setTilesIndex,
      required this.showGrid,
      required this.setPixel,
      required this.selectedTileIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TileListView(
          onTap: (index) => setTilesIndex(index),
          tiles: tiles,
          selectedTile: selectedTileIndex),
      Expanded(
        //padding: const EdgeInsets.all(8.0),
        child: _gridView(),
      ),
      Expanded(
        flex: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: BackgroundWidget(
                  background: preview,
                  tiles: tiles,
                  onTap: null,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: GraphicsDataDisplay(
                  graphics: tiles,
                ),
              ),
            )
          ],
        ),
      )
    ]);
  }

  Widget _gridView() {
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
        onTap: (indexPixel) => {
          setPixel(indexPixel, indexTile)
        },
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
