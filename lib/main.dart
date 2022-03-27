import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tile.dart';
import 'package:gbdk_graphic_editor/tiles.dart';
import 'package:gbdk_graphic_editor/widgets/background/background_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/background/background_editor.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tiles_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tiles_editor.dart';

import 'background.dart';
import 'file_utils.dart';
import 'graphics.dart';

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
  var tileBuffer = <int>[]; // copy / past tiles buffer

  @override
  void initState() {
    super.initState();
    tiles.tileList.add(Tile());
    background =
        Background(width: 20, height: 18, name: "Background", tiles: tiles);
  }

  @override
  Widget build(BuildContext context) {
    TilesAppBar tileappbar = TilesAppBar(
      preferredSize: const Size.fromHeight(50.0),
      tiles: tiles,
      rightShift: _rightShift,
      leftShift: _leftShift,
      setIntensity: _setIntensity,
      selectedIntensity: selectedIntensity,
      addTile: _addTile,
      removeTile: _removeTile,
      setTileMode: _setTileMode,
      toggleGridTile: _toggleGridTile,
      showGrid: showGridTile,
      setTileFromSource: _setTilesFromSource,
      setTilesDimensions: _setTilesDimensions,
      selectedTileIndexTile: selectedTileIndexTile,
      saveGraphics: _saveGraphics,
    );

    BackgroundAppBar backgroundappbar = BackgroundAppBar(
      preferredSize: const Size.fromHeight(50.0),
      setTileMode: _setTileMode,
      toggleGridBackground: _toggleGridBackground,
      showGrid: showGridBackground,
      setBackgroundFromSource: _setBackgroundFromSource,
      background: background,
      selectedTileIndex: selectedTileIndexBackground,
      saveGraphics: _saveGraphics,
    );

    dynamic appbar;
    if (tileMode) {
      appbar = tileappbar;
    } else {
      appbar = backgroundappbar;
    }

    return Scaffold(
        appBar: appbar,
        body: ContextMenuOverlay(
            child: tileMode
                ? TilesEditor(
                    tiles: tiles,
                    onRemove: _removeTile,
                    onInsert: _addTile,
                    copy: _copy,
                    past: _past,
                    setIndex: _setTileIndexTile,
                    setPixel: _setPixel,
                    showGrid: showGridTile,
                    selectedIndex: selectedTileIndexTile,
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

  _saveGraphics(Graphics graphics, BuildContext context) {
    saveToDirectory(graphics).then((selectedDirectory) {
      if (selectedDirectory != null) {
        var snackBar = SnackBar(
          content: Text(
              "${graphics.name}.h and ${graphics.name}.c saved under $selectedDirectory"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
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
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  List<int> toMeta() {
    var metaTile = <int>[];

    if (tiles.width == 8 && tiles.height == 8) {
      return tiles.getMetaTileAtIndex(selectedTileIndexTile);
    }
    if (tiles.width == 8 && tiles.height == 16) {
      return tiles.getMetaTileAtIndex(selectedTileIndexTile);
    } else if (tiles.width == 16 && tiles.height == 16) {
      for (int indexRow = 0; indexRow < Tiles.size; indexRow++) {
        metaTile += tiles.getRow(0 + 4 * selectedTileIndexTile, indexRow);
        metaTile += tiles.getRow(2 + 4 * selectedTileIndexTile, indexRow);
      }

      for (int indexRow = 0; indexRow < Tiles.size; indexRow++) {
        metaTile += tiles.getRow(1 + 4 * selectedTileIndexTile, indexRow);
        metaTile += tiles.getRow(3 + 4 * selectedTileIndexTile, indexRow);
      }
    } else if (tiles.width == 32 && tiles.height == 32) {
      //TODO
    }

    return metaTile;
  }

  List<int> fromMeta() {
    var data = List<int>.filled(tiles.width * tiles.height, 0, growable: true);

    if (tiles.width == 8 && tiles.height == 8) {
      return tiles.getMetaTileAtIndex(selectedTileIndexTile);
    } else if (tiles.width == 8 && tiles.height == 16) {
      return tiles.getMetaTileAtIndex(selectedTileIndexTile);
    } else if (tiles.width == 16 && tiles.height == 16) {
      for (int rowIndex = 0; rowIndex < Tiles.size * 4; rowIndex += 2) {
        int halfRow = rowIndex ~/ 2;
        int from = halfRow * Tiles.size;
        data.replaceRange(from, from + Tiles.size,
            tiles.getRow(4 * selectedTileIndexTile, rowIndex));
        from = tiles.pixelPerTile() * 2 + halfRow * Tiles.size;
        data.replaceRange(from, from + Tiles.size,
            tiles.getRow(4 * selectedTileIndexTile, rowIndex + 1));
      }
    } else if (tiles.width == 32 && tiles.height == 32) {
      //TODO
    }
    return data;
  }

  void _rightShift() => setState(() {
        int from = tiles.width * tiles.height * selectedTileIndexTile;
        int to = from + tiles.width * tiles.height;
        tiles.data.replaceRange(from, to, toMeta());
        for (int index = from; index < to; index += tiles.width) {
          var row = tiles.data.sublist(index, index + tiles.width);
          tiles.data.replaceRange(index, index + tiles.width, _shift(row, -1));
        }
        tiles.data.replaceRange(from, to, fromMeta());
      });

  void _leftShift() => setState(() {
        int from = tiles.width * tiles.height * selectedTileIndexTile;
        int to = from + tiles.width * tiles.height;
        tiles.data.replaceRange(from, to, toMeta());
        for (int index = from; index < to; index += tiles.width) {
          var row = tiles.data.sublist(index, index + tiles.width);
          tiles.data.replaceRange(index, index + tiles.width, _shift(row, 1));
        }
        tiles.data.replaceRange(from, to, fromMeta());
      });

  void _copy(int index) => setState(() {
        tileBuffer = tiles.data.sublist(index * tiles.width * tiles.height,
            index * tiles.width * tiles.height + tiles.width * tiles.height);
      });

  void _past(int index) => setState(() {
        tiles.data.replaceRange(
            index * tiles.width * tiles.height,
            index * tiles.width * tiles.height + tiles.width * tiles.height,
            tileBuffer);
      });

  void _addTile(int index) => setState(() {
        tiles.tileList.add(Tile());
        tiles.data.insertAll(index * tiles.width * tiles.height,
            List.filled(tiles.width * tiles.height, 0));
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
      tiles.tileList[selectedTileIndexTile].data[indexPixel] = selectedIntensity;
    });
  }
}

String formatSource(String source) {
  LineSplitter ls = const LineSplitter();
  List<String> lines = ls.convert(source);
  return lines.join();
}
