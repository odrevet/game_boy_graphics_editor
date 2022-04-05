import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/meta_tile.dart';
import 'package:gbdk_graphic_editor/tile.dart';
import 'package:gbdk_graphic_editor/widgets/background/background_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/background/background_editor.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tiles_app_bar.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tiles_editor.dart';
import 'package:image/image.dart' as image;

import 'background.dart';
import 'colors.dart';
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
  var metaTile = MetaTile(name: "Tiles");
  late Background background;
  int selectedMetaTileIndexTile = 0;
  int selectedTileIndexBackground = 0;
  bool tileMode = true; // edit tile or map
  bool showGridTile = true;
  bool floodMode = false;
  bool showGridBackground = true;
  var tileBuffer = <int>[]; // copy / past tiles buffer
  List<Color> colorSet = colorsPocket;

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
      floodMode: floodMode,
      toggleFloodMode: _toggleFloodMode,
      toggleColorSet: _toggleColorSet,
      loadTileFromFilePicker: loadTileFromFilePicker,
      setTilesDimensions: _setTilesDimensions,
      metaTileIndex: selectedMetaTileIndexTile,
      saveGraphics: _saveGraphics,
      colorSet: colorSet,
      flipHorizontal: flipHorizontal,
      flipVertical: flipVertical,
      rotateLeft: rotateLeft,
      rotateRight: rotateRight,
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
        body: tileMode
            ? TilesEditor(
                metaTile: metaTile,
                onRemove: _removeMetaTile,
                onInsert: _addMetaTile,
                copy: _copy,
                past: _past,
                setIndex: _setTileIndexTile,
                setPixel: _setPixel,
                showGrid: showGridTile,
                floodMode: floodMode,
                selectedIndex: selectedMetaTileIndexTile,
                colorSet: colorSet,
                preview: Background(
                    width: 4, height: 4, fill: selectedMetaTileIndexTile))
            : BackgroundEditor(
                background: background,
                colorSet: colorSet,
                tiles: metaTile,
                selectedTileIndex: selectedTileIndexBackground,
                onTapTileListView: _setTileIndexBackground,
                showGrid: showGridBackground,
              ));
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

  void _toggleFloodMode() => setState(() {
        floodMode = !floodMode;
      });

  void _toggleColorSet() => setState(() {
        colorSet == colorsDMG ? colorSet = colorsPocket : colorSet = colorsDMG;
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
        var rowTemp = metaTile.getRow(selectedMetaTileIndexTile, 0);

        for (int indexRow = 0; indexRow < metaTile.height - 1; indexRow++) {
          var row = metaTile.getRow(selectedMetaTileIndexTile, indexRow + 1);
          metaTile.setRow(selectedMetaTileIndexTile, indexRow, row);
        }

        metaTile.setRow(
            selectedMetaTileIndexTile, metaTile.height - 1, rowTemp);
      });

  void _downShift() => setState(() {
        var rowTemp =
            metaTile.getRow(selectedMetaTileIndexTile, metaTile.height - 1);

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

  bool _setMetaTile(GraphicElement graphicElement) {
    bool hasLoaded = true;
    setState(() {
      try {
        metaTile.setData(graphicElement.values.split(','));
        metaTile.name = graphicElement.name;
      } catch (e) {
        hasLoaded = false;
      }

      if (hasLoaded) selectedMetaTileIndexTile = 0;
      _setTilesDimensions(8, 8);
    });
    return hasLoaded;
  }

  void _setBackgroundFromSource(String source) => setState(() {
        source = background.formatSource(source);
        background.fromSource(source);
        selectedTileIndexBackground = 0;
      });

  _setPixel(int rowIndex, int colIndex) => setState(() => metaTile.setPixel(
      rowIndex, colIndex, selectedMetaTileIndexTile, selectedIntensity));

  flipHorizontal() {
    var metaTileTemp = _newMetaTile();

    for (int rowIndex = 0; rowIndex < metaTile.height; rowIndex++) {
      for (int colIndex = 0; colIndex < metaTile.width; colIndex++) {
        int intensity = metaTile.getPixel(
            rowIndex, metaTile.width - 1 - colIndex, selectedMetaTileIndexTile);
        metaTileTemp.setPixel(rowIndex, colIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTileTemp);
  }

  flipVertical() {
    var metaTileTemp = _newMetaTile();

    for (int rowIndex = 0; rowIndex < metaTile.height; rowIndex++) {
      for (int colIndex = 0; colIndex < metaTile.width; colIndex++) {
        int intensity = metaTile.getPixel(
            metaTile.width - 1 - colIndex, rowIndex, selectedMetaTileIndexTile);
        metaTileTemp.setPixel(colIndex, rowIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTileTemp);
  }

  rotateLeft() {
    var metaTileTemp = _newMetaTile();

    for (int rowIndex = 0; rowIndex < metaTile.height; rowIndex++) {
      for (int colIndex = 0; colIndex < metaTile.width; colIndex++) {
        int intensity = metaTile.getPixel(
            metaTile.width - 1 - colIndex, rowIndex, selectedMetaTileIndexTile);
        metaTileTemp.setPixel(rowIndex, colIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTileTemp);
  }

  rotateRight() {
    var metaTileTemp = _newMetaTile();

    for (int rowIndex = 0; rowIndex < metaTile.height; rowIndex++) {
      for (int colIndex = 0; colIndex < metaTile.width; colIndex++) {
        int intensity = metaTile.getPixel(
            rowIndex, metaTile.width - 1 - colIndex, selectedMetaTileIndexTile);
        metaTileTemp.setPixel(colIndex, rowIndex, 0, intensity);
      }
    }

    _setMetaTileData(metaTileTemp);
  }

  _newMetaTile() {
    var metaTileTemp = MetaTile(width: metaTile.width, height: metaTile.height);
    for (int i = 0; i < metaTile.nbTilePerMetaTile(); i++) {
      metaTileTemp.tileList.add(Tile());
    }
    return metaTileTemp;
  }

  _setMetaTileData(MetaTile metaTileTemp) {
    setState(() {
      for (int rowIndex = 0; rowIndex < metaTile.width; rowIndex++) {
        for (int colIndex = 0; colIndex < metaTile.height; colIndex++) {
          int intensity = metaTileTemp.getPixel(rowIndex, colIndex, 0);
          metaTile.setPixel(
              rowIndex, colIndex, selectedMetaTileIndexTile, intensity);
        }
      }
    });
  }

  bool loadTileFromFilePicker(result) {
    bool isPng = result.names[0]!.endsWith('.png');
    late bool hasLoaded;
    if (isPng) {
      var img = image.decodePng(File(result.paths[0]!).readAsBytesSync())!;

      img = image.grayscale(img);

      if (img.width % Tile.size != 0 || img.height % Tile.size != 0) {
        var snackBar = const SnackBar(
          content:
              Text("Image height and width should be multiple of ${Tile.size}"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }

      metaTile.tileList.clear();
      int nbColors = colorSet.length - 1;
      for (int rowIndexTile = 0;
          rowIndexTile < img.height;
          rowIndexTile += Tile.size) {
        for (int colIndexTile = 0;
            colIndexTile < img.width;
            colIndexTile += Tile.size) {
          var tile = Tile();
          for (int rowIndex = 0; rowIndex < Tile.size; rowIndex++) {
            for (int colIndex = 0; colIndex < Tile.size; colIndex++) {
              int pixel = img.getPixelSafe(
                  rowIndex + rowIndexTile, colIndex + colIndexTile);
              int intensity =
                  nbColors - (((pixel & 0xff) / 0xff) * nbColors).round();
              tile.setPixel(rowIndex, colIndex, intensity);
            }
          }
          metaTile.tileList.add(tile);
        }
      }

      hasLoaded = true;
    } else {
      readBytes(result).then((source) {
        source = metaTile.formatSource(source);
        var graphicsElements = metaTile.fromGBDKSource(source);
        if (graphicsElements.length > 1) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Tile data selection'),
                    content: SizedBox(
                      height: 200.0,
                      width: 150.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: graphicsElements.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              hasLoaded = _setMetaTile(graphicsElements[index]);
                              Navigator.pop(context);
                            },
                            title: Text(graphicsElements[index].name),
                          );
                        },
                      ),
                    ),
                  ));
        } else if (graphicsElements.length == 1) {
          hasLoaded = _setMetaTile(graphicsElements.first);
        } else {
          hasLoaded = false;
        }
      });
    }
    return hasLoaded;
  }
}
