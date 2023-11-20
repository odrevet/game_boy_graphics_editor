import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_settings.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';

import '../../models/download_stub.dart'
    if (dart.library.html) '../../models/download.dart';
import '../models/file_utils.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';
import 'background/background_settings.dart';

class ApplicationMenuBar extends StatelessWidget {
  const ApplicationMenuBar({super.key});

  _saveGraphics(Graphics graphics, String name, SourceConverter sourceConverter,
      BuildContext context) {
    saveToDirectory(graphics, name, sourceConverter).then((selectedDirectory) {
      if (selectedDirectory != null) {
        var snackBar = SnackBar(
          content: Text("$name.h and $name.c saved under $selectedDirectory"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  bool _setMetaTile(GraphicElement graphicElement, BuildContext context) {
    bool hasLoaded = true;
    try {
      context.read<AppStateCubit>().setTileName(graphicElement.name);
      var data =
          GBDKTileConverter().fromSource(graphicElement.values.split(','));
      data = GBDKTileConverter().reorderFromSourceToCanvas(
          data,
          context.read<MetaTileCubit>().state.width,
          context.read<MetaTileCubit>().state.height);
      context.read<MetaTileCubit>().setData(data);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR $e");
      }
      hasLoaded = false;
    }

    if (hasLoaded) context.read<AppStateCubit>().setSelectedTileIndex(0);

    return hasLoaded;
  }

  bool loadTileFromFilePicker(result, BuildContext context) {
    bool isPng = result.names[0]!.endsWith('.png');
    bool hasLoaded = false;
    if (isPng) {
      /*var img = image.decodePng(File(result.paths[0]!).readAsBytesSync())!;

      img = image.grayscale(img);

      if (img.width % MetaTile.tileSize != 0 ||
          img.height % MetaTile.tileSize != 0) {
        var snackBar = SnackBar(
          content: Text(
              "Image height and width should be multiple of ${MetaTile.tileSize}"),
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

      hasLoaded = true;*/
    } else {
      readBytes(result).then((source) {
        source = GBDKTileConverter().formatSource(source);
        var graphicsElements =
            GBDKTileConverter().readGraphicElementsFromSource(source);
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
                                  graphicsElements[index], context);
                              Navigator.pop(context);
                            },
                            title: Text(graphicsElements[index].name),
                          );
                        },
                      ),
                    ),
                  ));
        } else if (graphicsElements.length == 1) {
          hasLoaded = _setMetaTile(graphicsElements.first, context);
        } else {
          hasLoaded = false;
        }
      });
    }
    return hasLoaded;
  }

  void _setBackgroundFromSource(String source, BuildContext context) {
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

  void _setBackgroundFromBin(List<int> raw, BuildContext context) {
    Graphics graphics = Background(data: raw);
    context.read<BackgroundCubit>().setData(graphics.data);
    context.read<BackgroundCubit>().setWidth(graphics.width);
    context.read<BackgroundCubit>().setHeight(graphics.height);
    context.read<AppStateCubit>().setTileIndexBackground(0);
    context.read<AppStateCubit>().setBackgroundName("data");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: MenuBar(
            children: <Widget>[
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      selectFile([
                        'c' /*, 'png'*/
                      ]).then((result) {
                        late SnackBar snackBar;
                        if (result == null) {
                          snackBar = const SnackBar(
                            content: Text("Not loaded"),
                          );
                        } else {
                          //bool hasLoaded = false;
                          if (context.read<AppStateCubit>().state.tileMode) {
                            loadTileFromFilePicker(result, context);
                          } else {
                            readBytes(result).then(
                                (raw) => _setBackgroundFromSource(raw, context));
                          }
                          /*snackBar = SnackBar(
                            content: Text(
                                hasLoaded ? "Data loaded" : "Data not loaded"),
                          );*/
                        }
                        //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    child: const MenuAcceleratorLabel('&Open'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      selectFile(['bin']).then((result) {
                        late SnackBar snackBar;
                        if (result == null) {
                          snackBar = const SnackBar(
                            content: Text("Not loaded"),
                          );
                        } else {
                          //bool hasLoaded = false;
                          if (context.read<AppStateCubit>().state.tileMode) {
                            readBin(result).then((bytes) {
                              String values = "";
                              for (int byte in bytes) {
                                // Convert each byte to a hexadecimal string
                                values +=
                                    byte.toRadixString(16).padLeft(2, '0');
                              }

                              var data = GBDKTileConverter().fromSource(
                                  formatHexPairs(values).split(','));
                              data = GBDKTileConverter()
                                  .reorderFromSourceToCanvas(
                                      data,
                                      context.read<MetaTileCubit>().state.width,
                                      context
                                          .read<MetaTileCubit>()
                                          .state
                                          .height);
                              context.read<MetaTileCubit>().setData(data);
                            });
                          } else {
                            readBin(result).then((bytes) {
                              String values = "";
                              for (int byte in bytes) {
                                // Convert each byte to a hexadecimal string
                                values +=
                                    byte.toRadixString(16).padLeft(2, '0');
                              }
                              var data = <int>[];
                              for (var index = 0; index < values.length; index += 2) {
                                data.add(
                                    int.parse("${values[index]}${values[index+1]}", radix: 16));
                              }
                              _setBackgroundFromBin(data, context);
                            });
                          }
                          /*snackBar = SnackBar(
                            content: Text(
                                hasLoaded ? "Data loaded" : "Data not loaded"),
                          );*/
                        }
                        //ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    child: const MenuAcceleratorLabel('&Open bin'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      if (context.read<AppStateCubit>().state.tileMode) {
                        if (kIsWeb) {
                          download(
                              GBDKTileConverter().toHeader(
                                  context.read<MetaTileCubit>().state,
                                  context.read<AppStateCubit>().state.tileName),
                              '${context.read<AppStateCubit>().state.tileName}.h');
                          download(
                              GBDKTileConverter().toSource(
                                  context.read<MetaTileCubit>().state,
                                  context.read<AppStateCubit>().state.tileName),
                              '${context.read<AppStateCubit>().state.tileName}.c');
                        } else {
                          _saveGraphics(
                              context.read<MetaTileCubit>().state,
                              context.read<AppStateCubit>().state.tileName,
                              GBDKTileConverter(),
                              context);
                        }
                      } else {
                        saveToDirectory(
                            context.read<BackgroundCubit>().state,
                            context.read<AppStateCubit>().state.backgroundName,
                            GBDKBackgroundConverter());
                      }
                    },
                    child: const MenuAcceleratorLabel('Save as &source code'),
                  ),
                  /*MenuItemButton(
                    onPressed: () {
                      saveFileBin(utf8.encode(GBDKTileConverter()
                          .toBin(context.read<MetaTileCubit>().state)), ['.bin'], 'data');
                    },
                    child: const MenuAcceleratorLabel('Save as &bin'),
                  ),*/
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),

              // View
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () => context
                            .read<AppStateCubit>()
                            .state
                            .tileMode
                        ? context.read<AppStateCubit>().toggleGridTile()
                        : context.read<AppStateCubit>().toggleGridBackground(),
                    child: const MenuAcceleratorLabel('Toggle &grid'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&View'),
              ),

              // Mode
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () =>
                        context.read<AppStateCubit>().setMode(true),
                    child: const MenuAcceleratorLabel('Tile'),
                  ),
                  MenuItemButton(
                    onPressed: () =>
                        context.read<AppStateCubit>().setMode(false),
                    child: const MenuAcceleratorLabel('Background'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&Mode'),
              ),

              // Edit
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext alertDialogContext) =>
                              AlertDialog(
                                title: const Text('Settings'),
                                content:
                                    context.read<AppStateCubit>().state.tileMode
                                        ? const TileSettings()
                                        : const BackgroundSettings(),
                              ));
                    },
                    child: const MenuAcceleratorLabel('Settings'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&Edit'),
              ),

              MenuItemButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GameBoy Graphics Editor',
                    applicationVersion: '1.0.1',
                  );
                },
                child: const MenuAcceleratorLabel('&About'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
