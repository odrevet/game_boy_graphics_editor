import 'dart:io';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:image/image.dart' as img;
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

onFileOpen(BuildContext context) {
  selectFile(['c', 'h']).then((result) {
    late SnackBar snackBar;
    if (result == null) {
      snackBar = const SnackBar(
        content: Text("Not loaded"),
      );
    } else {
      //bool hasLoaded = false
      if (context.read<AppStateCubit>().state.tileMode) {
        _loadTileFromFilePicker(result, context);
      } else {
        readString(result)
            .then((source) => _setBackgroundFromSource(source, context));
      }
    }
  });
}

_setBinFromBytes(BuildContext context, List<int> bytes) {
  if (context.read<AppStateCubit>().state.tileMode) {
    var data = GBDKTileConverter().fromSource(bytes);
    data = GBDKTileConverter().reorderFromSourceToCanvas(
        data,
        context.read<MetaTileCubit>().state.width,
        context.read<MetaTileCubit>().state.height);
    context.read<MetaTileCubit>().setData(data);
  } else {
    String values = "";
    for (int byte in bytes) {
      // Convert each byte to a hexadecimal string
      values += byte.toRadixString(16).padLeft(2, '0');
    }
    var data = <int>[];
    for (var index = 0; index < values.length; index += 2) {
      data.add(int.parse("${values[index]}${values[index + 1]}", radix: 16));
    }
    _setBackgroundFromBin(data, context);
  }
}

onFileOpenBin(BuildContext context) {
  selectFile(['*']).then((result) {
    if (result != null) {
      readBin(result).then((bytes) {
        _setBinFromBytes(context, bytes);
      });
    }
  });
}

onFileOpenBinRLE(BuildContext context) {
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
    saveSourceToDirectory(
        context.read<BackgroundCubit>().state,
        context.read<AppStateCubit>().state.backgroundName,
        GBDKBackgroundConverter());
  }
}

onFileSaveAsBinTile(BuildContext context) async {
  saveBinToDirectoryTile(context.read<MetaTileCubit>().state,
      context.read<AppStateCubit>().state.tileName);
}

onFileSaveAsBinBackground(BuildContext context) async {
  saveBinToDirectoryBackground(context.read<BackgroundCubit>().state,
      context.read<AppStateCubit>().state.backgroundName);
}

onFileTilesSaveAsPNG(BuildContext context) async {
  FilePicker.platform.getDirectoryPath().then((selectedDirectory) {
    if (selectedDirectory != null) {
      MetaTile metaTile = context.read<MetaTileCubit>().state;
      List<Color> colorSet = context.read<AppStateCubit>().state.colorSet;
      String tileName = context.read<AppStateCubit>().state.tileName;
      int count = context.read<MetaTileCubit>().count();

      final image =
          img.Image(width: metaTile.width * count, height: metaTile.height);
      for (int tileIndex = 0; tileIndex < count; tileIndex++) {
        var tile = metaTile.getTileAtIndex(tileIndex);
        for (int pixelIndex = 0;
            pixelIndex < metaTile.width * metaTile.height;
            pixelIndex++) {
          //get color in source tile
          var color = colorSet[tile[pixelIndex]];

          // get coordinate in destination image and set pixel
          int x = pixelIndex % metaTile.width + tileIndex * metaTile.width;
          int y = pixelIndex ~/ metaTile.width;
          var pixel = image.getPixel(x, y);
          pixel.setRgb(color.red, color.green, color.blue);
        }
      }

      final png = img.encodePng(image);
      File("$selectedDirectory/$tileName.png").writeAsBytesSync(png);
    }
  });
}

onFileBackgroundSaveAsPNG(BuildContext context) async {
  FilePicker.platform.getDirectoryPath().then((selectedDirectory) {
    if (selectedDirectory != null) {
      MetaTile metaTile = context.read<MetaTileCubit>().state;
      Background background = context.read<BackgroundCubit>().state;
      List<Color> colorSet = context.read<AppStateCubit>().state.colorSet;
      String backgroundName =
          context.read<AppStateCubit>().state.backgroundName;

      final image = img.Image(
          width: background.width * metaTile.width,
          height: background.height * metaTile.height);
      for (int backgroundIndex = 0;
          backgroundIndex < background.width * background.height;
          backgroundIndex++) {
        var tile = metaTile.getTileAtIndex(background.data[backgroundIndex]);

        for (int pixelIndex = 0;
            pixelIndex < metaTile.width * metaTile.height;
            pixelIndex++) {
          //get color in source tile
          var color = colorSet[tile[pixelIndex]];

          // get coordinate in destination image and set pixel
          int x =
              pixelIndex % metaTile.width + backgroundIndex * metaTile.width;
          int y = pixelIndex ~/ metaTile.width +
              (backgroundIndex ~/ background.width) * (metaTile.height - 1);
          var pixel = image.getPixel(x, y);

          pixel.setRgb(color.red, color.green, color.blue);
        }
      }

      final png = img.encodePng(image);
      File("$selectedDirectory/$backgroundName.png").writeAsBytesSync(png);
    }
  });
}

_saveGraphics(Graphics graphics, String name, SourceConverter sourceConverter,
    BuildContext context) {
  saveSourceToDirectory(graphics, name, sourceConverter)
      .then((selectedDirectory) {
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

bool _loadTileFromFilePicker(result, BuildContext context) {
  bool hasLoaded = false;
  readString(result).then((source) {
    source = GBDKTileConverter().formatSource(source);

    Map<String, int> defines =
        GBDKTileConverter().readDefinesFromSource(source);
    _setPropertiesFromDefines(defines, context);

    var graphicsElements =
        GBDKTileConverter().readGraphicElementsFromSource(source);
    if (graphicsElements.length > 1) {
      hasLoaded = _showGraphicElementChooseDialog(
          context, graphicsElements, _setTilesFromGraphicElement);
    } else if (graphicsElements.length == 1) {
      hasLoaded = _setMetaTile(graphicsElements.first, context);
    } else {
      hasLoaded = false;
    }
  });
  return hasLoaded;
}

bool _setTilesFromGraphicElement(
    GraphicElement graphicElement, BuildContext context) {
  return _setMetaTile(graphicElement, context);
}

bool _setBackgroundFromGraphicElement(
    GraphicElement graphicElement, BuildContext context) {
  Background background = GBDKBackgroundConverter().fromGraphicElementTransposed(
      graphicElement);
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
    Background background =
        GBDKBackgroundConverter().fromGraphicElement(graphicsElements[0]);
    context.read<BackgroundCubit>().setData(background.data);
    context.read<AppStateCubit>().setTileIndexBackground(0);
  }
}

void _setBackgroundFromBin(List<int> raw, BuildContext context) {
  Graphics graphics = Background(data: raw);
  context.read<BackgroundCubit>().setData(graphics.data);
  context.read<AppStateCubit>().setTileIndexBackground(0);
  context.read<AppStateCubit>().setBackgroundName("data");
}

Future<void> saveFile(String content, allowedExtensions, [filename]) async {
  String? fileName = await FilePicker.platform
      .saveFile(allowedExtensions: allowedExtensions, fileName: filename);
  if (fileName != null) {
    File file = File(fileName);
    file.writeAsString(content);
  }
}

Future<void> saveFileBin(List<int> content, allowedExtensions,
    [filename]) async {
  String? fileName = await FilePicker.platform
      .saveFile(allowedExtensions: allowedExtensions, fileName: filename);
  if (fileName != null) {
    File file = File(fileName);
    file.writeAsBytes(Uint8List.fromList(content));
  }
}

Future<String?> saveSourceToDirectory(
    Graphics graphics, String name, SourceConverter sourceConverter) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    File("$selectedDirectory/$name.h")
        .writeAsString(sourceConverter.toHeader(graphics, name));
    File("$selectedDirectory/$name.c")
        .writeAsString(sourceConverter.toSource(graphics, name));
  }

  return selectedDirectory;
}

Future<String?> saveBinToDirectoryTile(Graphics graphics, String name) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    List<int> bytes = GBDKTileConverter()
        .getRawTileInt(GBDKTileConverter().reorderFromCanvasToSource(graphics));

    File("$selectedDirectory/$name.bin").writeAsBytesSync(bytes);
  }

  return selectedDirectory;
}

Future<String?> saveBinToDirectoryBackground(
    Graphics graphics, String name) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    List<int> bytes = graphics.data;
    File("$selectedDirectory/$name.bin").writeAsBytesSync(bytes);
  }

  return selectedDirectory;
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
