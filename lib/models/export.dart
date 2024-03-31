import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:image/image.dart' as img;

import '../../models/download_stub.dart'
    if (dart.library.html) '../../models/download.dart';
import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';

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

onFileSaveAsSourceCode(BuildContext context, String parse) {
  if (parse == 'Tile') {
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
    if (kIsWeb) {
      download(
          GBDKBackgroundConverter().toHeader(
              context.read<BackgroundCubit>().state,
              context.read<AppStateCubit>().state.backgroundName),
          '${context.read<AppStateCubit>().state.backgroundName}.h');
      download(
          GBDKBackgroundConverter().toSource(
              context.read<BackgroundCubit>().state,
              context.read<AppStateCubit>().state.backgroundName),
          '${context.read<AppStateCubit>().state.backgroundName}.c');
    } else {
      _saveGraphics(
          context.read<BackgroundCubit>().state,
          context.read<AppStateCubit>().state.backgroundName,
          GBDKBackgroundConverter(),
          context);
    }
  }
}

onFileSaveAsBinTile(BuildContext context) async {
  if (kIsWeb) {
    List<int> bytes = GBDKTileConverter().getRawTileInt(GBDKTileConverter()
        .reorderFromCanvasToSource(context.read<MetaTileCubit>().state));

    download(
        bytes.join(), '${context.read<AppStateCubit>().state.tileName}.bin');
  } else {
    saveBinToDirectoryTile(context.read<MetaTileCubit>().state,
        context.read<AppStateCubit>().state.tileName);
  }
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
