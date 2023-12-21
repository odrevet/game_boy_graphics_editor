import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/download_stub.dart'
    if (dart.library.html) '../../models/download.dart';
import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';

onImport(BuildContext context, bool tile, String type, bool transpose,
    bool decompress) {
  selectFile(['*']).then((result) {
    if (result != null) {
      if (type == 'Binary') {
        readBin(result).then((List<int> content) {
          if (tile) {
            List<int> data = GBDKTileConverter().combine(content);
            data = GBDKTileConverter().reorderFromSourceToCanvas(
                data,
                context.read<MetaTileCubit>().state.width,
                context.read<MetaTileCubit>().state.height);
            context.read<MetaTileCubit>().setData(data);
          } else {
            String values = "";
            for (int byte in content) {
              // Convert each byte to a hexadecimal string
              values += byte.toRadixString(16).padLeft(2, '0');
            }
            var data = <int>[];
            for (var index = 0; index < values.length; index += 2) {
              data.add(
                  int.parse("${values[index]}${values[index + 1]}", radix: 16));
            }
            if (transpose) {
              _setBackgroundFromBinTransposed(data, context);
            } else {
              _setBackgroundFromBin(data, context);
            }
          }
        });
      } else {
        readString(result).then((String source) {
          if (tile) {
            _setTilesFromSource(source, context);
          } else {
            _setBackgroundFromSource(source, context);
          }
        });
      }
    }
  });
}

void _setTilesFromSource(String source, BuildContext context) {
  source = GBDKTileConverter().formatSource(source);

  Map<String, int> defines = GBDKTileConverter().readDefinesFromSource(source);
  _setPropertiesFromDefines(defines, context);

  var graphicsElements =
      GBDKTileConverter().readGraphicElementsFromSource(source);
  if (graphicsElements.length > 1) {
    _showGraphicElementChooseDialog(
        context, graphicsElements, _setMetaTile);
  } else if (graphicsElements.length == 1) {
    _setMetaTile(graphicsElements.first, context);
  }
}

void _setBackgroundFromSource(String source, BuildContext context) {
  source = GBDKBackgroundConverter().formatSource(source);

  Map<String, int> defines =
      GBDKBackgroundConverter().readDefinesFromSource(source);
  _setPropertiesFromDefines(defines, context);

  var graphicsElements =
      GBDKBackgroundConverter().readGraphicElementsFromSource(source);
  if (graphicsElements.length > 1) {
    _showGraphicElementChooseDialog(
        context, graphicsElements, _setBackgroundFromGraphicElement);
  } else if (graphicsElements.length == 1) {
    context.read<AppStateCubit>().setTileIndexBackground(0);
    _setBackgroundFromGraphicElement(graphicsElements.first, context);
  }
}

/*onFileOpenBinRLE(BuildContext context) {
  selectFile(['*']).then((result) {
    if (result != null) {
      // decompress to a temp file
      var systemTempDir = Directory.systemTemp;
      String inputPath = result.files.single.path!;
      String outputPath = "${systemTempDir.path}/decompressed.bin";

      Process.runSync(
          '${context.read<AppStateCubit>().state.gbdkPath}/gbcompress',
          ['-d', '--alg=rle', inputPath, outputPath]);

      // read decompressed data and tmp delete file
      File decompressed = File(outputPath);
      if (decompressed.existsSync()) {
        var bytes = decompressed.readAsBytesSync();
        _setBinFromBytes(context, bytes);
        decompressed.deleteSync();
      }
    }
  });
}*/

bool _setMetaTile(GraphicElement graphicElement, BuildContext context) {
  bool hasLoaded = true;
  try {
    context.read<AppStateCubit>().setTileName(graphicElement.name);
    var data = GBDKTileConverter().combine(graphicElement.values);
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

bool _setBackgroundFromGraphicElement(
    GraphicElement graphicElement, BuildContext context) {
  Background background =
      GBDKBackgroundConverter().fromGraphicElement(graphicElement);
  context.read<BackgroundCubit>().setData(background.data);
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
                      onTap(graphicsElements[index], context);
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

void _setBackgroundFromBin(List<int> raw, BuildContext context) {
  Graphics graphics = Background(data: raw);
  context.read<BackgroundCubit>().setData(graphics.data);
  context.read<AppStateCubit>().setBackgroundName("data");
}

void _setBackgroundFromBinTransposed(List<int> raw, BuildContext context) {
  Background background = Background(
      data: List.filled(raw.length, 0),
      height: context.read<BackgroundCubit>().state.height,
      width: context.read<BackgroundCubit>().state.width);

  int x = 0;
  int y = 0;
  for (int index = 0; index < raw.length; index++) {
    int value = raw[index];

    background.setDataAt(x, y, value);

    y++;
    if (y >= background.height) {
      y = 0;
      x++;
    }
  }

  context.read<BackgroundCubit>().setData(background.data);
  context.read<AppStateCubit>().setBackgroundName("data");
}

Future<FilePickerResult?> selectFile(List<String> allowedExtensions) async =>
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

Future<String> readString(FilePickerResult filePickerResult) async {
  if (kIsWeb) {
    Uint8List? bytes = filePickerResult.files.single.bytes;
    return String.fromCharCodes(bytes!);
  } else {
    File file = File(filePickerResult.files.single.path!);
    return await file.readAsString();
  }
}

Future<List<int>> readBin(FilePickerResult filePickerResult) async {
  if (kIsWeb) {
    return filePickerResult.files.single.bytes!;
  } else {
    File file = File(filePickerResult.files.single.path!);
    return await file.readAsBytes();
  }
}
