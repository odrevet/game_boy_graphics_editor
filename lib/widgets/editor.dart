import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/models/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/tile.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_app_bar.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_editor.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_app_bar.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_editor.dart';
import 'package:image/image.dart' as image;

import '../models/app_state.dart';
import '../models/background.dart';
import '../models/file_utils.dart';
import '../models/graphics.dart';

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late Background background;

  @override
  void initState() {
    super.initState();
    background = Background(width: 20, height: 18, name: "Background");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) => BlocBuilder<MetaTileCubit, MetaTile>(
        builder: (context, metaTile) {
          TilesAppBar tileappbar = TilesAppBar(
            preferredSize: const Size.fromHeight(50.0),
            metaTile: metaTile,
            setTileMode: () => context.read<AppStateCubit>().toggleTileMode(),
            toggleColorSet: () => context.read<AppStateCubit>().toggleColorSet(),
            loadTileFromFilePicker: loadTileFromFilePicker,
            saveGraphics: _saveGraphics,
          );

          BackgroundAppBar backgroundappbar = BackgroundAppBar(
            preferredSize: const Size.fromHeight(50.0),
            setBackgroundFromSource: _setBackgroundFromSource,
            background: background,
            saveGraphics: _saveGraphics,
          );

          dynamic appbar;
          if (appState.tileMode) {
            appbar = tileappbar;
          } else {
            appbar = backgroundappbar;
          }

          return Scaffold(
              appBar: appbar,
              body: appState.tileMode
                  ? TilesEditor(
                      preview: Background(width: 4, height: 4, fill: appState.metaTileIndexTile))
                  : BackgroundEditor(
                      background: background,
                      colorSet: appState.colorSet,
                      tiles: metaTile,
                      selectedTileIndex: appState.tileIndexBackground,
                      onTapTileListView: (index) =>
                          context.read<AppStateCubit>().setTileIndexBackground(index),
                      showGrid: appState.showGridBackground,
                    ));
        },
      ),
    );
  }

  _saveGraphics(Graphics graphics, BuildContext context) {
    saveToDirectory(graphics).then((selectedDirectory) {
      if (selectedDirectory != null) {
        var snackBar = SnackBar(
          content: Text("${graphics.name}.h and ${graphics.name}.c saved under $selectedDirectory"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  bool _setMetaTile(GraphicElement graphicElement, metaTile) {
    bool hasLoaded = true;
    setState(() {
      try {
        metaTile.setData(graphicElement.values.split(','));
        metaTile.name = graphicElement.name;
      } catch (e) {
        hasLoaded = false;
      }

      if (hasLoaded) context.read<AppStateCubit>().setSelectedTileIndex(0);
      context.read<MetaTileCubit>().setDimensions(8, 8);
    });
    return hasLoaded;
  }

  void _setBackgroundFromSource(String source) => setState(() {
        source = background.formatSource(source);
        background.fromSource(source);
        context.read<AppStateCubit>().setTileIndexBackground(0);
      });

  bool loadTileFromFilePicker(result, metaTile) {
    bool isPng = result.names[0]!.endsWith('.png');
    late bool hasLoaded;
    if (isPng) {
      var img = image.decodePng(File(result.paths[0]!).readAsBytesSync())!;

      img = image.grayscale(img);

      if (img.width % Tile.size != 0 || img.height % Tile.size != 0) {
        var snackBar = const SnackBar(
          content: Text("Image height and width should be multiple of ${Tile.size}"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }

      metaTile.tileList.clear();
      int nbColors = context.read<AppStateCubit>().state.colorSet.length - 1;
      for (int rowIndexTile = 0; rowIndexTile < img.height; rowIndexTile += Tile.size) {
        for (int colIndexTile = 0; colIndexTile < img.width; colIndexTile += Tile.size) {
          var tile = Tile();
          for (int rowIndex = 0; rowIndex < Tile.size; rowIndex++) {
            for (int colIndex = 0; colIndex < Tile.size; colIndex++) {
              int pixel = img.getPixelSafe(rowIndex + rowIndexTile, colIndex + colIndexTile);
              int intensity = nbColors - (((pixel & 0xff) / 0xff) * nbColors).round();
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
                              hasLoaded = _setMetaTile(graphicsElements[index], metaTile);
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
