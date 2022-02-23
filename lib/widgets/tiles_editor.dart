import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/map_widget.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import '../tiles.dart';

class TilesEditor extends StatelessWidget {
  final Tiles tiles;
  final Function setTilesIndex;
  final Function setPixel;

  const TilesEditor(
      {Key? key,
      required this.tiles,
      required this.setTilesIndex,
      required this.setPixel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TileListView(onTap: (index) => setTilesIndex(index), tiles: tiles),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TileWidget(
              onTap: setPixel, intensity: tiles.getData(tiles.index)),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MapWidget(
                mapHeight: 4,
                mapWidth: 4,
                mapData: List.filled(16, tiles.index, growable: false),
                tileData: tiles.data,
                tileSize: tiles.size,
                onTap: null,
              ),
            ),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(tiles.toSource()))),
          ],
        ),
      )
    ]);
  }
}
