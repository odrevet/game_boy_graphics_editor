import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/download_stub.dart'
    if (dart.library.html) '../../models/download.dart';
import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/file_utils.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';

onFileOpen(BuildContext context) {
  selectFile(['c']).then((result) {
    late SnackBar snackBar;
    if (result == null) {
      snackBar = const SnackBar(
        content: Text("Not loaded"),
      );
    } else {
      //bool hasLoaded = false;
      if (context.read<AppStateCubit>().state.tileMode) {
        _loadTileFromFilePicker(result, context);
      } else {
        readBytes(result)
            .then((source) => _setBackgroundFromSource(source, context));
      }
    }
  });
}

onFileOpenBin(BuildContext context) {
  selectFile(['*']).then((result) {
    if (result == null) {
    } else {
      if (context.read<AppStateCubit>().state.tileMode) {
        readBin(result).then((bytes) {
          var data = GBDKTileConverter().fromSource(bytes);
          data = GBDKTileConverter().reorderFromSourceToCanvas(
              data,
              context.read<MetaTileCubit>().state.width,
              context.read<MetaTileCubit>().state.height);
          context.read<MetaTileCubit>().setData(data);
        });
      } else {
        readBin(result).then((bytes) {
          String values = "";
          for (int byte in bytes) {
            // Convert each byte to a hexadecimal string
            values += byte.toRadixString(16).padLeft(2, '0');
          }
          var data = <int>[];
          for (var index = 0; index < values.length; index += 2) {
            data.add(
                int.parse("${values[index]}${values[index + 1]}", radix: 16));
          }
          _setBackgroundFromBin(data, context);
        });
      }
    }
  });
}

onFileSaveAsSourceCode(BuildContext context) {
  if (context.read<AppStateCubit>().state.tileMode) {
    if (kIsWeb) {
      download(
          GBDKTileConverter().toHeader(context.read<MetaTileCubit>().state,
              context.read<AppStateCubit>().state.tileName),
          '${context.read<AppStateCubit>().state.tileName}.h');
      download(
          GBDKTileConverter().toSource(context.read<MetaTileCubit>().state,
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
}

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
    var data = GBDKTileConverter().fromSource(graphicElement.values);
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

bool _loadTileFromFilePicker(result, BuildContext context) {
  bool isPng = result.names[0]!.endsWith('.png');
  bool hasLoaded = false;
  readBytes(result).then((source) {
    source = GBDKTileConverter().formatSource(source);
    var graphicsElements =
        GBDKTileConverter().readGraphicElementsFromSource(source);
    if (graphicsElements.length > 1) {
      hasLoaded = _showGraphicElementChooseDialog(
          context, graphicsElements, _onTapTile);
    } else if (graphicsElements.length == 1) {
      hasLoaded = _setMetaTile(graphicsElements.first, context);
    } else {
      hasLoaded = false;
    }
  });
  return hasLoaded;
}

bool _onTapTile(GraphicElement graphicElement, context) {
  return _setMetaTile(graphicElement, context);
}

bool onTapBackground(GraphicElement graphicElement, BuildContext context) {
  Background background =
      GBDKBackgroundConverter().fromGraphicElement(graphicElement);
  context.read<BackgroundCubit>().setData(background.data);
  context.read<AppStateCubit>().setTileIndexBackground(0);
  return true;
}

_showGraphicElementChooseDialog(BuildContext context,
    List<GraphicElement> graphicsElements, Function onTap) {
  bool hasLoaded = false;
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('Graphic element selection'),
            content: SizedBox(
              height: 200.0,
              width: 150.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: graphicsElements.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      hasLoaded = _onTapTile(graphicsElements[index], context);
                      Navigator.pop(context);
                    },
                    title: Text(graphicsElements[index].name),
                  );
                },
              ),
            ),
          ));

  return hasLoaded;
}

void _setBackgroundFromSource(String source, BuildContext context) {
  source = GBDKTileConverter().formatSource(source);
  var graphicsElements =
      GBDKBackgroundConverter().readGraphicElementsFromSource(source);
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
                        onTapBackground(graphicsElements[index], context);
                        Navigator.pop(context);
                      },
                      title: Text(graphicsElements[index].name),
                    );
                  },
                ),
              ),
            ));
  } else if (graphicsElements.length == 1) {
    Background background =
        GBDKBackgroundConverter().fromGraphicElement(graphicsElements[0]);
    context.read<BackgroundCubit>().setData(background.data);
    context.read<AppStateCubit>().setTileIndexBackground(0);
  }
}

void _setBackgroundFromBin(List<int> raw, BuildContext context) {
  Graphics graphics = Background(data: raw);
  context.read<BackgroundCubit>().setData(graphics.data);
  context.read<BackgroundCubit>().setWidth(graphics.width);
  context.read<BackgroundCubit>().setHeight(graphics.height);
  context.read<AppStateCubit>().setTileIndexBackground(0);
  context.read<AppStateCubit>().setBackgroundName("data");
}
