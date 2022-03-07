import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';
import 'package:gbdk_graphic_editor/widgets/background_editor.dart';
import 'package:gbdk_graphic_editor/widgets/gbdk_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/tiles_editor.dart';

import 'background.dart';

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
        fontFamily: 'RobotoMono',
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
  var selectedIntensity = 0;
  var tiles = Tiles(name: "Tiles", data: List.filled(64, 0, growable: true), width: 8, height: 8);
  late Background background;
  int selectedTileIndexTile = 0;
  int selectedTileIndexBackground = 0;
  bool tileMode = true; // edit tile or map
  bool showGridTile = true;
  bool showGridBackground = true;

  @override
  void initState() {
    super.initState();
    background =
        Background(width: 20, height: 18, name: "Background", tiles: tiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GBDKAppBar(
            setIntensity: _setIntensity,
            selectedIntensity: selectedIntensity,
            tileMode: tileMode,
            addTile: _addTile,
            removeTile: _removeTile,
            setTileMode: _setTileMode,
            toggleGridTile: _toggleGridTile,
            showGridTile: showGridTile,
            toggleGridBackground: _toggleGridBackground,
            showGridBackground: showGridBackground,
            preferredSize: const Size.fromHeight(50.0),
            setTileFromSource: _setTilesFromSource,
            setBackgroundFromSource: _setBackgroundFromSource,
            tiles: tiles,
            background: background,
            selectedTileIndexTile: selectedTileIndexTile,
            selectedTileIndexBackground: selectedTileIndexBackground),
        body: tileMode
            ? TilesEditor(
                setTilesIndex: _setTileIndexTile,
                setPixel: _setPixel,
                tiles: tiles,
                showGrid: showGridTile,
                selectedTileIndex: selectedTileIndexTile,
                preview: Background(
                    width: 4, height: 4, fill: selectedTileIndexTile))
            : BackgroundEditor(
                background: background,
                tiles: tiles,
                selectedTileIndex: selectedTileIndexBackground,
                onTapTileListView: _setTileIndexBackground,
                showGrid: showGridBackground,
              ));
  }

  void _setTileIndexBackground(index) => setState(() {
        selectedTileIndexBackground = index;
      });

  void _setTileIndexTile(index) => setState(() {
        selectedTileIndexTile = index;
      });

  void _toggleGridTile() => setState(() {
        showGridTile = !showGridTile;
      });

  void _toggleGridBackground() => setState(() {
        showGridBackground = !showGridBackground;
      });

  void _setIntensity(intensity) => setState(() {
        selectedIntensity = intensity;
      });

  void _addTile() => setState(() {
        tiles.count += 1;
        tiles.data += List.filled(64, 0);
      });

  void _removeTile() => setState(() {
        tiles.count -= 1;
        tiles.data.removeRange(
            selectedTileIndexTile * 64, (selectedTileIndexTile + 1) * 64);

        selectedTileIndexTile--;
        if (selectedTileIndexTile < 0) {
          selectedTileIndexTile = 0;
        }

        selectedTileIndexBackground--;
        if (selectedTileIndexBackground < 0) {
          selectedTileIndexBackground = 0;
        }

        if (tiles.count == 0) {
          _addTile();
          selectedTileIndexTile = 0;
          selectedTileIndexBackground = 0;
        }
      });

  void _setTileMode() => setState(() {
        tileMode = !tileMode;
      });

  void _setTilesFromSource(source) => setState(() {
        source = formatSource(source);
        tiles.fromSource(source);
        selectedTileIndexTile = 0;
      });

  void _setBackgroundFromSource(String source) => setState(() {
        source = formatSource(source);
        background.fromSource(source);
        selectedTileIndexBackground = 0;
      });

  _setPixel(int index) {
    index += (tiles.width * tiles.height) * selectedTileIndexTile;
    setState(() {
      tiles.data[index] = selectedIntensity;
    });
  }
}

String formatSource(String source) {
  LineSplitter ls = const LineSplitter();
  List<String> lines = ls.convert(source);
  return lines.join();
}
