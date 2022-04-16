import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gbdk_graphic_editor/meta_tile.dart';
import 'package:gbdk_graphic_editor/meta_tile_cubit.dart';
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
      home: BlocProvider(create: (_) => MetaTileCubit(), child: const Editor()),
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
    background = Background(width: 20, height: 18, name: "Background");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetaTileCubit, MetaTile>(
      builder: (context, metaTile) {
        TilesAppBar tileappbar = TilesAppBar(
          preferredSize: const Size.fromHeight(50.0),
          metaTile: metaTile,
          setIntensity: _setIntensity,
          selectedIntensity: selectedIntensity,
          setTileMode: _setTileMode,
          toggleGridTile: _toggleGridTile,
          showGrid: showGridTile,
          floodMode: floodMode,
          toggleFloodMode: _toggleFloodMode,
          toggleColorSet: _toggleColorSet,
          loadTileFromFilePicker: loadTileFromFilePicker,
          metaTileIndex: selectedMetaTileIndexTile,
          saveGraphics: _saveGraphics,
          colorSet: colorSet,
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
                    selectedIntensity: selectedIntensity,
                    setIndex: _setTileIndexTile,
                    showGrid: showGridTile,
                    floodMode: floodMode,
                    selectedIndex: selectedMetaTileIndexTile,
                    colorSet: colorSet,
                    tileBuffer: tileBuffer,
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
      },
    );
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

  void _setTileMode() => setState(() {
        tileMode = !tileMode;
      });

  bool _setMetaTile(GraphicElement graphicElement, metaTile) {
    bool hasLoaded = true;
    setState(() {
      try {
        metaTile.setData(graphicElement.values.split(','));
        metaTile.name = graphicElement.name;
      } catch (e) {
        hasLoaded = false;
      }

      if (hasLoaded) selectedMetaTileIndexTile = 0;
      context.read<MetaTileCubit>().setDimensions(8, 8);
    });
    return hasLoaded;
  }

  void _setBackgroundFromSource(String source) => setState(() {
        source = background.formatSource(source);
        background.fromSource(source);
        selectedTileIndexBackground = 0;
      });

  bool loadTileFromFilePicker(result, metaTile) {
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
                              hasLoaded = _setMetaTile(
                                  graphicsElements[index], metaTile);
                              Navigator.pop(context);
                            },
                            title: Text(graphicsElements[index].name),
                          );
                        },
                      ),
                    ),
                  ));
        } else if (graphicsElements.length == 1) {
          hasLoaded = _setMetaTile(graphicsElements.first, metaTile);
        } else {
          hasLoaded = false;
        }
      });
    }
    return hasLoaded;
  }
}
