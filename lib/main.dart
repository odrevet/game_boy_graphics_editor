import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';
import 'package:gbdk_graphic_editor/widgets/gbdk_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/map_editor.dart';
import 'package:gbdk_graphic_editor/widgets/tiles_editor.dart';

import 'background.dart';
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
  var background = Background(1, 1, 0);
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
        body: tileMode
            ? TilesEditor(
                setTilesIndex: _setTileIndex,
                setPixel: _setPixel,
                tiles: tiles,
                preview: Background(4, 4, tiles.index))
            : MapEditor(
                setTilesIndex: _setTileIndex,
                background: background,
                tiles: tiles,
                setMapData: _setMapData,
                setMapWidth: _setMapWidth,
                setMapHeight: _setMapHeight,
              ));
  }

  void _setMapWidth(value) => setState(() {
        background.width = int.parse(value);
        background.data = List.filled(background.height * background.width, 0);
      });

  void _setMapHeight(value) => setState(() {
        background.height = int.parse(value);
        background.data = List.filled(background.height * background.width, 0);
      });

  void _setMapData(index) => setState(() {
        background.data[index] = tiles.index;
      });

  void _setTileIndex(index) => setState(() {
        tiles.index = index;
      });

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

  _setPixel(int index) {
    index += (tiles.size * tiles.size) * tiles.index;
    setState(() {
      tiles.data[index] = selectedIntensity;
    });
  }
}
