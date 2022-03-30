import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/meta_tile.dart';
import 'package:gbdk_graphic_editor/tile.dart';
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
  var metaTile =
      MetaTile(name: "Tiles", data: List.filled(64, 0, growable: true));
  late Background background;
  int selectedMetaTileIndexTile = 0;
  int selectedTileIndexBackground = 0;
  bool tileMode = true; // edit tile or map
  bool showGridTile = true;
  bool showGridBackground = true;
  var tileBuffer = <int>[]; // copy / past tiles buffer

  @override
  void initState() {
    super.initState();
    metaTile.tileList.add(Tile());
    background =
        Background(width: 20, height: 18, name: "Background", tiles: metaTile);
  }

  @override
  Widget build(BuildContext context) {
    TilesAppBar tileappbar = TilesAppBar(
      preferredSize: const Size.fromHeight(50.0),
      metaTile: metaTile,
      rightShift: _rightShift,
      leftShift: _leftShift,
      upShift: _upShift,
      downShift: _downShift,
      setIntensity: _setIntensity,
      selectedIntensity: selectedIntensity,
      addMetaTile: _addMetaTile,
      removeMetaTile: _removeMetaTile,
      setTileMode: _setTileMode,
      toggleGridTile: _toggleGridTile,
      showGrid: showGridTile,
      setTileFromSource: _setTilesFromSource,
      setTilesDimensions: _setTilesDimensions,
      metaTileIndex: selectedMetaTileIndexTile,
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
                    metaTile: metaTile,
                    onRemove: _removeMetaTile,
                    onInsert: _addMetaTile,
                    copy: _copy,
                    past: _past,
                    setIndex: _setTileIndexTile,
                    setPixel: _setPixel,
                    showGrid: showGridTile,
                    selectedIndex: selectedMetaTileIndexTile,
                    preview: Background(
                        width: 4, height: 4, fill: selectedMetaTileIndexTile))
                : BackgroundEditor(
                    background: background,
                    tiles: metaTile,
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
        metaTile.width = width;
        metaTile.height = height;
        int numberOfTilesNecessary =
            metaTile.nbTilePerMetaTile() - metaTile.tileList.length;

        for (int i = 0; i < numberOfTilesNecessary; i++) {
          metaTile.tileList.add(Tile());
        }
        selectedMetaTileIndexTile = 0;
      });

  void _setTileIndexBackground(index) => setState(() {
        selectedTileIndexBackground = index;
      });

  void _setTileIndexTile(index) => setState(() {
        selectedMetaTileIndexTile = index;
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

  void _rightShift() => setState(() {
        for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
          var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow);
          row.replaceRange(0, row.length, _shift(row, -1));
          metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
        }
      });

  void _leftShift() => setState(() {
        for (int indexRow = 0; indexRow < metaTile.height; indexRow++) {
          var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow);
          row.replaceRange(0, row.length, _shift(row, 1));
          metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
        }
      });

  void _upShift() => setState(() {
  });

  void _downShift() => setState(() {
    var rowTemp = metaTile.getRow(selectedMetaTileIndexTile, metaTile.height - 1);

    for (int indexRow = metaTile.height - 1; indexRow > 0; indexRow--) {
      var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow - 1);
      metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
    }

    metaTile.setRow(selectedMetaTileIndexTile, 0, rowTemp);
  });

  void _copy(int index) => setState(() {
        tileBuffer.clear();
        for (var i = index; i < index + metaTile.nbTilePerMetaTile(); i++) {
          tileBuffer.addAll(metaTile.tileList[i].data);
        }
      });

  void _past(int index) => setState(() {
        for (var i = 0; i < tileBuffer.length; i++) {
          int tileIndex =
              i ~/ Tile.pixelPerTile + index * metaTile.nbTilePerMetaTile();
          metaTile.tileList[tileIndex].data[i % 64] = tileBuffer[i];
        }
      });

  void _addMetaTile(int index) => setState(() {
        var newMetaTile =
            List<Tile>.generate(metaTile.nbTilePerMetaTile(), (_) => Tile());
        metaTile.tileList
            .insertAll(index * metaTile.nbTilePerMetaTile(), newMetaTile);
        selectedMetaTileIndexTile = index;
      });

  void _removeMetaTile(int index) => setState(() {
        metaTile.tileList.removeRange(
            index * metaTile.nbTilePerMetaTile(),
            index * metaTile.nbTilePerMetaTile() +
                metaTile.nbTilePerMetaTile());
        selectedMetaTileIndexTile = index - 1;

        if (metaTile.tileList.isEmpty) {
          _addMetaTile(0);
        }
      });

  void _setTileMode() => setState(() {
        tileMode = !tileMode;
      });

  bool _setTilesFromSource(source) {
    late bool hasLoaded;
    setState(() {
      source = formatSource(source);
      hasLoaded = metaTile.fromSource(source);

      if (hasLoaded) selectedMetaTileIndexTile = 0;
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
      metaTile.tileList[indexTile].data[indexPixel] = selectedIntensity;
    });
  }
}

String formatSource(String source) {
  LineSplitter ls = const LineSplitter();
  List<String> lines = ls.convert(source);
  return lines.join();
}
