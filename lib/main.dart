import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';
import 'package:gbdk_graphic_editor/widgets/gbdk_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/map_widget.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import 'convert.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBDK Graphic Editor',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const Editor(),
    );
  }
}

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int mapHeight = 1;
  int mapWidth = 1;
  var mapData = List.filled(1, 0, growable: true);
  var selectedIntensity = 0;
  var tiles = Tiles();
  bool tileMode = true; // edit tile or map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GBDKAppBar(
            setIntensity: _setIntensity,
            tileMode: tileMode,
            addTile: _addTile,
            setTileMode: _setTileMode,
            preferredSize: const Size.fromHeight(50.0),
            setTileFromSource: _setTilesFromSource,
            tiles: tiles),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: tileMode ? _buildTile() : _buildMap(),
        ));
  }

  void _setIntensity(intensity) => setState(() {
        selectedIntensity = intensity;
      });

  void _addTile() => setState(() {
        tiles.count += 1;
        tiles.data += List.filled(64, 0);
      });

  void _setTileMode() => setState(() {
        tileMode = !tileMode;
      });

  void _setTilesFromSource(name, values) => setState(() {
        tiles.name = name;
        tiles.data.clear();
        tiles.data = getIntensityFromRaw(values.split(','), tiles.size);
        tiles.index = 0;
        tiles.count = tiles.data.length ~/ (tiles.size * tiles.size);
      });

  _buildTile() {
    var tileListView = TileListView(
        onTap: (index) => setState(() {
              tiles.index = index;
            }),
        tiles: tiles);

    return [
      tileListView,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TileWidget(
              onTap: _setPixel, intensity: tiles.getData(tiles.index)),
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
    ];
  }

  _buildMap() {
    var tileListView = TileListView(
      onTap: (index) => setState(() {
        tiles.index = index;
      }),
      tiles: tiles,
    );

    return [
      tileListView,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MapWidget(
          mapHeight: mapHeight,
          mapWidth: mapWidth,
          mapData: mapData,
          tileData: tiles.data,
          tileSize: tiles.size,
          onTap: (index) => setState(() {
            mapData[index] = tiles.index;
          }),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            Text('Height $mapHeight'),
            TextField(
              onChanged: (text) => setState(() {
                mapHeight = int.parse(text);
                mapData = List.filled(mapHeight * mapWidth, 0);
              }),
            ),
            Text('Width $mapWidth'),
            TextField(
              onChanged: (text) => setState(() {
                mapWidth = int.parse(text);
                mapData = List.filled(mapHeight * mapWidth, 0);
              }),
            ),
            Flexible(
              child:
                  SelectableText(mapData.map((e) => decimalToHex(e)).join(",")),
            ),
          ],
        ),
      )
    ];
  }

  _setPixel(int index) {
    index += (tiles.size * tiles.size) * tiles.index;
    setState(() {
      tiles.data[index] = selectedIntensity;
    });
  }
}
