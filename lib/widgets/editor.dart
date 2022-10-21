import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_tile_converter.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_app_bar.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_editor.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_app_bar.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_editor.dart';
import 'package:image/image.dart' as image;

import '../models/app_state.dart';
import '../models/file_utils.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/source_converter.dart';

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  @override
  void initState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) => BlocBuilder<MetaTileCubit, MetaTile>(
        builder: (context, metaTile) {
          TilesAppBar tileappbar = TilesAppBar(
            preferredSize: const Size.fromHeight(50.0),
            loadTileFromFilePicker: loadTileFromFilePicker,
            saveGraphics: () => _saveGraphics(metaTile,
                context.read<AppStateCubit>().state.tileName, GBDKTileConverter(), context),
          );

          BackgroundAppBar backgroundappbar = BackgroundAppBar(
            preferredSize: const Size.fromHeight(50.0),
            setBackgroundFromSource: _setBackgroundFromSource,
            saveGraphics: () => _saveGraphics(
                context.read<BackgroundCubit>().state,
                context.read<AppStateCubit>().state.backgroundName,
                GBDKBackgroundConverter(),
                context),
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
                  ? const TilesEditor()
                  : BackgroundEditor(
                      tiles: metaTile,
                      onTapTileListView: (index) =>
                          context.read<AppStateCubit>().setTileIndexBackground(index),
                      showGrid: appState.showGridBackground,
                    ));
        },
      ),
    );
  }

  _saveGraphics(
      Graphics graphics, String name, SourceConverter sourceConverter, BuildContext context) {
    saveToDirectory(graphics, name, sourceConverter).then((selectedDirectory) {
      if (selectedDirectory != null) {
        var snackBar = SnackBar(
          content: Text("$name.h and $name.c saved under $selectedDirectory"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  bool _setMetaTile(GraphicElement graphicElement) {
    bool hasLoaded = true;
    try {
      context.read<AppStateCubit>().setTileName(graphicElement.name);
      var data = GBDKTileConverter().fromSource(graphicElement.values.split(','));
      data = GBDKTileConverter().reorderFromSourceToCanvas(data,
          context.read<MetaTileCubit>().state.width, context.read<MetaTileCubit>().state.height);
      context.read<MetaTileCubit>().setData(data);
    } catch (e) {
      //print("ERROR $e");
      hasLoaded = false;
    }

    if (hasLoaded) context.read<AppStateCubit>().setSelectedTileIndex(0);

    return hasLoaded;
  }

  void _setBackgroundFromSource(String source) {
    source = GBDKBackgroundConverter().formatSource(source);
    List nameGraphics = GBDKBackgroundConverter().fromSource(source);
    String name = nameGraphics[0];
    Graphics graphics = nameGraphics[1];
    context.read<BackgroundCubit>().setData(graphics.data);
    context.read<BackgroundCubit>().setWidth(graphics.width);
    context.read<BackgroundCubit>().setHeight(graphics.height);
    context.read<AppStateCubit>().setTileIndexBackground(0);
    context.read<AppStateCubit>().setBackgroundName(name);
  }

  bool loadTileFromFilePicker(result) {
    bool isPng = result.names[0]!.endsWith('.png');
    bool hasLoaded = false;
    if (isPng) {
      var img = image.decodePng(File(result.paths[0]!).readAsBytesSync())!;

      img = image.grayscale(img);

      if (img.width % MetaTile.tileSize != 0 || img.height % MetaTile.tileSize != 0) {
        var snackBar = SnackBar(
          content: Text("Image height and width should be multiple of ${MetaTile.tileSize}"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }

      int nbColors = context.read<AppStateCubit>().state.colorSet.length - 1;
      var data = <int>[];
      for (int rowIndexTile = 0; rowIndexTile < img.height; rowIndexTile++) {
        for (int colIndexTile = 0; colIndexTile < img.width; colIndexTile++) {
          final int pixel = img.getPixelSafe(colIndexTile, rowIndexTile);
          data.add(nbColors - (((pixel & 0xff) / 0xff) * nbColors).round());
        }
      }

      context.read<AppStateCubit>().setTileName(result.names[0].split('.')[0]);
      context.read<MetaTileCubit>().setData(data);

      hasLoaded = true;
    } else {
      readBytes(result).then((source) {
        source = GBDKTileConverter().formatSource(source);
        var graphicsElements = GBDKTileConverter().readGraphicElementsFromSource(source);
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
