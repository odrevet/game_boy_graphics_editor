import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';

import '../../models/download_stub.dart'
    if (dart.library.html) '../../models/download.dart';
import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';
import 'export.dart';

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

      tilesSaveAsPNG(metaTile, colorSet, tileName, count, selectedDirectory);
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

      backgroundSaveAsPNG(
          background, metaTile, colorSet, backgroundName, selectedDirectory);
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
