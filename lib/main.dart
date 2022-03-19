import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';
import 'package:gbdk_graphic_editor/widgets/background/background_editor.dart';
import 'package:gbdk_graphic_editor/widgets/gbge_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tiles_editor.dart';

import 'background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Boy Graphic Editor',
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
  var selectedIntensity = 3;
  var tiles = Tiles(name: "Tiles", data: List.filled(64, 0, growable: true));
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
        appBar: GBGEAppBar(
            rightShift: _rightShift,
            leftShift: _leftShift,
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
            setTilesDimensions: _setTilesDimensions,
            setBackgroundFromSource: _setBackgroundFromSource,
            tiles: tiles,
            background: background,
            selectedTileIndexTile: selectedTileIndexTile,
            selectedTileIndexBackground: selectedTileIndexBackground),
        body: ContextMenuOverlay(
            child: tileMode
                ? TilesEditor(
                    onRemoveTile: _removeTile,
                    onInsertTile: _addTile,
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
                  )));
  }

  void _setTilesDimensions(width, height) => setState(() {
        tiles.width = width;
        tiles.height = height;
        int numberOfTilesNecessary =
            (tiles.data.length / (tiles.width * tiles.height)).ceil();

        // resize tile data if necessary
        if (numberOfTilesNecessary > tiles.count()) {
          setState(() {
            tiles.data += List.filled(
                (numberOfTilesNecessary - tiles.count()) *
                    (tiles.width * tiles.height),
                0);
          });
        }

        // reset selected index to prevent being out of bound (TODO reset on current new index)
        selectedTileIndexTile = 0;
      });

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

  List<int> _shift(List<int> list, int v) {
    if (list.isEmpty) return list;
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  void _rightShift() => setState(() {
        int from = tiles.width * tiles.height * selectedTileIndexTile;
        int to = from + tiles.width * tiles.height;
        for (int index = from; index < to; index += Tiles.size) {
          var tile = tiles.data.sublist(index, index + Tiles.size);
          tiles.data.replaceRange(index, index + Tiles.size, _shift(tile, -1));
        }
      });

  void _leftShift() => setState(() {
        int from = tiles.width * tiles.height * selectedTileIndexTile;
        int to = from + tiles.width * tiles.height;
        for (int index = from; index < to; index += Tiles.size) {
          var tile = tiles.data.sublist(index, index + Tiles.size);
          tiles.data.replaceRange(index, index + Tiles.size, _shift(tile, 1));
        }
      });

  void _addTile(int index) => setState(() {
        tiles.data.insertAll(index * tiles.width * tiles.height, List.filled(tiles.width * tiles.height, 0));
      });

  void _removeTile(int index) => setState(() {
        tiles.data.removeRange(index * tiles.width * tiles.height,
            (index + 1) * tiles.width * tiles.height);

        selectedTileIndexTile--;
        if (selectedTileIndexTile < 0) {
          selectedTileIndexTile = 0;
        }

        selectedTileIndexBackground--;
        if (selectedTileIndexBackground < 0) {
          selectedTileIndexBackground = 0;
        }

        if (tiles.count() == 0) {
          _addTile(0);
          selectedTileIndexTile = 0;
          selectedTileIndexBackground = 0;
        }
      });

  void _setTileMode() => setState(() {
        tileMode = !tileMode;
      });

  bool _setTilesFromSource(source) {
    late bool hasLoaded;
    setState(() {
      source = formatSource(source);
      hasLoaded = tiles.fromSource(source);

      if (hasLoaded) selectedTileIndexTile = 0;
      _setTilesDimensions(8, 8); //TODO read tiles dimensions in source comment
    });
    return hasLoaded;
  }

  void _setBackgroundFromSource(String source) => setState(() {
        source = formatSource(source);
        background.fromSource(source);
        selectedTileIndexBackground = 0;
      });

  _setPixel(int indexPixel, int indexTile) {
    setState(() {
      tiles.data[indexPixel +
          (Tiles.size *
              Tiles.size *
              (tiles.height ~/ Tiles.size) *
              (tiles.width ~/ Tiles.size) *
              selectedTileIndexTile) +
          (Tiles.size * Tiles.size * indexTile)] = selectedIntensity;
    });
  }
}

String formatSource(String source) {
  LineSplitter ls = const LineSplitter();
  List<String> lines = ls.convert(source);
  return lines.join();
}
