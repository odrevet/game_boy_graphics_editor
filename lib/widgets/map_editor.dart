import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/map_widget.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../convert.dart';
import '../tiles.dart';

class MapEditor extends StatelessWidget {
  final Tiles tiles;
  final Function setTilesIndex;
  final List<int> mapData;
  final int mapHeight;
  final int mapWidth;
  final Function setMapData;
  final Function setMapWidth;
  final Function setMapHeight;

  const MapEditor(
      {Key? key,
      required this.tiles,
      required this.setTilesIndex,
      required this.mapData,
      required this.mapHeight,
      required this.mapWidth,
      required this.setMapData,
      required this.setMapWidth,
      required this.setMapHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TileListView(onTap: (index) => setTilesIndex(index), tiles: tiles),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MapWidget(
            mapHeight: mapHeight,
            mapWidth: mapWidth,
            mapData: mapData,
            tileData: tiles.data,
            tileSize: tiles.size,
            onTap: (index) => setMapData(index)),
      ),
      Flexible(
        child: Column(
          children: [
            Text('Height $mapHeight'),
            TextField(
              onChanged: (text) => setMapHeight(text),
            ),
            Text('Width $mapWidth'),
            TextField(
              onChanged: (text) => setMapWidth(text),
            ),
            Flexible(
              child:
                  SelectableText(mapData.map((e) => decimalToHex(e)).join(",")),
            ),
          ],
        ),
      )
    ]);
  }
}
