import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/converter_utils.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import 'file_picker_utils.dart';

Future<List<Graphics>?> onImportHttp(
  BuildContext context,
  String parse,
  String type,
  bool transpose,
  String url,
) async {
  Uri uriObject = Uri.parse(url);

  if (type == 'Auto') {
    type = resolveType(uriObject.path);
  }

  if (type == 'Binary') {
    final bin = await http.readBytes(uriObject);
    List<int> data = convertBytesToDecimals(bin);
    var graphics = Graphics(name: "from bin", data: data);
    return [graphics];
  } else {
    final source = await http.read(uriObject);

    // using source converter (regexp based)
    //final formattedSource = GBDKTileConverter().formatSource(source);
    //final graphicsElements = GBDKTileConverter().readGraphicsFromSource(
    //  formattedSource,
    //);

    // using source parser (petitparser based)
    final parser = SourceParser();
    final graphicsElements = parser.parseAllArrays(source);

    return graphicsElements;
  }

  /*  bool tile = parse == 'Tile';
  Uri uriObject = Uri.parse(url);

  if (type == 'Auto') {
    type = resolveType(uriObject.path);
  }

  if (type == 'Binary') {
    http.readBytes(uriObject).then((content) {
      loadBin(content, tile, transpose, context);
    });
  } else {
    http.read(uriObject).then((source) {
      if (tile) {
        _setTilesFromSource(source, context);
      } else {
        _setBackgroundFromSource(source, context);
      }
    });
  }*/
}

/*onImport(
  BuildContext context,
  String type,
  bool transpose,
  String compression,
) {

  selectFile(['*']).then((result) {
    if (result != null) {
      if (type == 'Auto') {
        type = resolveType(result.files.single.name);
      }

      // WIP
//      if (type == 'Binary') {
//        if (compression != 'none') {
//          String inputPath = result.files.single.path!;
//          List<int> content = _decompress(inputPath, compression, context);
//          if (content.isNotEmpty) {
//            loadBin(content, tile, transpose, context);
//          }
//        } else {
//          readBin(result).then((List<int> content) {
//            loadBin(content, tile, transpose, context);
//          });
//        }
//      } else {
//        readString(result).then((String source) {
//          if (tile) {
//            _setTilesFromSource(source, context);
//          } else {
//            _setBackgroundFromSource(source, context);
//          }
//        });
//      }

      readString(result).then((String source) {
        source = GBDKTileConverter().formatSource(source);
        List<Graphics> graphicsElements = GBDKTileConverter()
            .readGraphicsFromSource(source);
        context.read<GraphicsCubit>().addGraphics(graphicsElements);
      });
    }
  });
}*/

Future<List<Graphics>?> onImport(
  BuildContext context,
  String type,
  bool transpose,
  String compression,
) async {
  final result = await selectFile(['*']);
  if (result == null) return null;

  if (type == 'Auto') {
    type = resolveType(result.files.single.name);
  }

  if (type == 'Binary') {
    //        if (compression != 'none') {
    //          String inputPath = result.files.single.path!;
    //          List<int> content = _decompress(inputPath, compression, context);
    //          if (content.isNotEmpty) {
    //            loadBin(content, tile, transpose, context);
    //          }

    final bin = await readBin(result);

    List<int> data = convertBytesToDecimals(bin);
    var graphics = Graphics(name: "from bin", data: data);
    return [graphics];
  } else {
    final source = await readString(result);

    // using source converter (regexp based)
    //final formattedSource = GBDKTileConverter().formatSource(source);
    //final graphicsElements = GBDKTileConverter().readGraphicsFromSource(
    //  formattedSource,
    //);

    // using source parser (petitparser based)
    final parser = SourceParser();
    final graphicsElements = parser.parseAllArrays(source);

    return graphicsElements;
  }
}

String resolveType(String path) {
  String extension = p.extension(path);
  if (extension == '.c' || extension == '.h') {
    return 'Source code';
  } else {
    return 'Binary';
  }
}

void loadBin(
  List<int> content,
  bool tile,
  bool transpose,
  BuildContext context,
) {
  if (tile) {
    List<int> data = GBDKTileConverter().combine(content);
    data = GBDKTileConverter().reorderFromSourceToCanvas(
      data,
      context.read<MetaTileCubit>().state.width,
      context.read<MetaTileCubit>().state.height,
    );
    context.read<MetaTileCubit>().setData(data);
  } else {
    List<int> data = convertBytesToDecimals(content);
    if (transpose) {
      _setBackgroundFromBinTransposed(data, context);
    } else {
      _setBackgroundFromBin(data, context);
    }
  }
}

void _setTilesFromSource(String source, BuildContext context) {
  source = GBDKTileConverter().formatSource(source);

  Map<String, int> defines = GBDKTileConverter().readDefinesFromSource(source);
  _setPropertiesFromDefines(defines, context);

  var graphicsElements = GBDKTileConverter().readGraphicsFromSource(source);
  if (graphicsElements.length > 1) {
    _showGraphicsChooseDialog(context, graphicsElements, _setMetaTile);
  } else if (graphicsElements.length == 1) {
    _setMetaTile(graphicsElements.first, context);
  }
}

void _setBackgroundFromSource(String source, BuildContext context) {
  source = GBDKBackgroundConverter().formatSource(source);

  Map<String, int> defines = GBDKBackgroundConverter().readDefinesFromSource(
    source,
  );
  _setPropertiesFromDefines(defines, context);

  var graphicsElements = GBDKBackgroundConverter().readGraphicsFromSource(
    source,
  );
  if (graphicsElements.length > 1) {
    _showGraphicsChooseDialog(
      context,
      graphicsElements,
      _setBackgroundFromGraphics,
    );
  } else if (graphicsElements.length == 1) {
    context.read<AppStateCubit>().setSelectedTileIndex(0);
    _setBackgroundFromGraphics(graphicsElements.first, context);
  }
}

List<int> _decompress(
  String inputPath,
  String compression,
  BuildContext context,
) {
  var content = <int>[];
  // decompress to a temp file
  var systemTempDir = Directory.systemTemp;
  String outputPath = "${systemTempDir.path}/decompressed.bin";

  Process.runSync(
    '${context.read<AppStateCubit>().state.gbdkPath}/gbcompress',
    ['-d', '--alg=$compression', inputPath, outputPath],
  );

  // read decompressed data and tmp delete file
  File decompressed = File(outputPath);
  if (decompressed.existsSync()) {
    content = decompressed.readAsBytesSync();
    decompressed.deleteSync();
  }

  return content;
}

bool _setMetaTile(Graphics Graphics, BuildContext context) {
  bool hasLoaded = true;
  try {
    context.read<AppStateCubit>().setTileName(Graphics.name);
    var data = GBDKTileConverter().combine(Graphics.data);
    data = GBDKTileConverter().reorderFromSourceToCanvas(
      data,
      context.read<MetaTileCubit>().state.width,
      context.read<MetaTileCubit>().state.height,
    );
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

void _setPropertiesFromDefines(Map<String, int> defines, BuildContext context) {
  defines.forEach((key, value) {
    if (key.endsWith('TILE_ORIGIN')) {
      context.read<BackgroundCubit>().setOrigin(value);
    } else if (key.endsWith('WIDTH')) {
      context.read<BackgroundCubit>().setWidth(value ~/ 8);
    } else if (key.endsWith('HEIGHT')) {
      context.read<BackgroundCubit>().setHeight(value ~/ 8);
    }
  });
}

bool _setBackgroundFromGraphics(Graphics Graphics, BuildContext context) {
  Background background = GBDKBackgroundConverter().fromGraphics(Graphics);
  context.read<BackgroundCubit>().setData(background.data);
  return true;
}

_showGraphicsChooseDialog(
  BuildContext context,
  List<Graphics> graphicsElements,
  Function onTap,
) {
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
                onTap(graphicsElements[index], context);
                Navigator.pop(context);
              },
              title: Text(graphicsElements[index].name),
            );
          },
        ),
      ),
    ),
  );

  return hasLoaded;
}

void _setBackgroundFromBin(List<int> raw, BuildContext context) {
  Graphics graphics = Background(data: raw);
  context.read<BackgroundCubit>().setData(graphics.data);
  context.read<AppStateCubit>().setBackgroundName("data");
}

void _setBackgroundFromBinTransposed(List<int> raw, BuildContext context) {
  raw = transpose(
    raw,
    context.read<BackgroundCubit>().state.height,
    context.read<BackgroundCubit>().state.width,
  );
  _setBackgroundFromBin(raw, context);
}
