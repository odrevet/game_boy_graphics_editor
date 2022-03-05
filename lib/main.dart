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
  var background = Background(width: 20, height: 18, name: "Background");
  var selectedIntensity = 0;
  var tiles = Tiles(name: "Tiles", data: List.filled(64, 0, growable: true));
  int selectedTileIndexTile = 0;
  int selectedTileIndexBackground = 0;
  bool tileMode = true; // edit tile or map
  bool showGrid = true;

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
            toggleGrid: _toggleGrid,
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
                showGrid: showGrid,
                selectedTileIndex: selectedTileIndexTile,
                preview: Background(
                    width: 4, height: 4, fill: selectedTileIndexTile))
            : BackgroundEditor(
                background: background,
                tiles: tiles,
                selectedTileIndex: selectedTileIndexBackground,
                onTapTileListView: _setTileIndexBackground,
              ));
  }

  void _setTileIndexBackground(index) => setState(() {
        selectedTileIndexBackground = index;
      });

  void _setTileIndexTile(index) => setState(() {
        selectedTileIndexTile = index;
      });

  void _toggleGrid() => setState(() {
        showGrid = !showGrid;
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

        selectedTileIndexTile = 0;

        if (tiles.count == 0) {
          _addTile();
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
    index += (tiles.size * tiles.size) * selectedTileIndexTile;
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
