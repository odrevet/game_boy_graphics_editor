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

void onFileSaveAsSourceCode(BuildContext context, String parse) {
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

void onFileSaveAsBinTile(BuildContext context) async {
  Graphics graphics = context.read<MetaTileCubit>().state;
  List<int> bytes = GBDKTileConverter()
      .getRawTileInt(GBDKTileConverter().reorderFromCanvasToSource(graphics));

  if (kIsWeb) {
    download(
        bytes.join(), '${context.read<AppStateCubit>().state.tileName}.bin');
  } else {
    String name = context.read<AppStateCubit>().state.tileName;
    String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      saveBin(bytes, directory, name);
    }
  }
}

void onFileSaveAsBinBackground(BuildContext context) async {
  Graphics graphics = context.read<BackgroundCubit>().state;
  String name = context.read<AppStateCubit>().state.backgroundName;
  List<int> bytes = graphics.data;

  if (kIsWeb) {
    download(
        bytes.join(), '$name.bin');
  }
  else {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      File("$directory/$name.bin").writeAsBytesSync(bytes);
    }
  }

}

void onFileTilesSaveAsPNG(BuildContext context) async {
  FilePicker.platform.getDirectoryPath().then((directory) {
    if (directory != null) {
      MetaTile metaTile = context.read<MetaTileCubit>().state;
      List<Color> colorSet = context.read<AppStateCubit>().state.colorSet;
      String tileName = context.read<AppStateCubit>().state.tileName;
      int count = context.read<MetaTileCubit>().count();

      tilesSaveToPNG(metaTile, colorSet, tileName, count, directory);
    }
  });
}

void onFileBackgroundSaveAsPNG(BuildContext context) async {
  FilePicker.platform.getDirectoryPath().then((directory) {
    if (directory != null) {
      MetaTile metaTile = context.read<MetaTileCubit>().state;
      Background background = context.read<BackgroundCubit>().state;
      List<Color> colorSet = context.read<AppStateCubit>().state.colorSet;
      String backgroundName =
          context.read<AppStateCubit>().state.backgroundName;

      backgroundSaveToPNG(
          background, metaTile, colorSet, backgroundName, directory);
    }
  });
}

void _saveGraphics(Graphics graphics, String name,
    SourceConverter sourceConverter, BuildContext context) {
  _saveSourceToDirectory(graphics, name, sourceConverter).then((directory) {
    if (directory != null) {
      var snackBar = SnackBar(
        content: Text("$name.h and $name.c saved under $directory"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  });
}

Future<String?> _saveSourceToDirectory(
    Graphics graphics, String name, SourceConverter sourceConverter) async {
  String? directory = await FilePicker.platform.getDirectoryPath();

  if (directory != null) {
    saveToSource(directory, name, sourceConverter, graphics);
  }

  return directory;
}
