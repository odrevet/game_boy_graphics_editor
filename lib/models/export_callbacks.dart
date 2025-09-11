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
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';
import 'png.dart';

void onFileSaveAsSourceCode(
  BuildContext context,
  String parse,
  Graphics graphics,
) {
  if (parse == 'Tile') {
    if (kIsWeb) {
      // Tile on Web
      download(
        GBDKTileConverter().toHeader(graphics, graphics.name),
        '${graphics.name}.h',
      );
      download(
        GBDKTileConverter().toSource(graphics, graphics.name),
        '${graphics.name}.c',
      );
    } else {
      // Tile on Desktop
      _saveGraphics(graphics, graphics.name, GBDKTileConverter(), context);
    }
  } else {
    if (kIsWeb) {
      // Background on Web
      download(
        GBDKBackgroundConverter().toHeader(graphics, graphics.name),
        '${graphics.name}.h',
      );
      download(
        GBDKBackgroundConverter().toSource(graphics, graphics.name),
        '${graphics.name}.c',
      );
    } else {
      // Background on Desktop
      _saveGraphics(
        graphics,
        graphics.name,
        GBDKBackgroundConverter(),
        context,
      );
    }
  }
}

void onFileSaveAsBinTile(BuildContext context, Graphics graphics) async {
  List<int> bytes = GBDKTileConverter().getRawTileInt(
    GBDKTileConverter().reorderFromCanvasToSource(graphics),
  );

  String name = graphics.name;

  if (kIsWeb) {
    download(bytes.join(), '${name}.bin');
  } else {
    String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      File("$directory/$name.bin").writeAsBytesSync(bytes);
    }
  }
}

void onFileSaveAsBinBackground(BuildContext context, Graphics graphics) async {
  String name = graphics.name;
  List<int> bytes = graphics.data;

  if (kIsWeb) {
    download(bytes.join(), '$name.bin');
  } else {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      File("$directory/$name.bin").writeAsBytesSync(bytes);
    }
  }
}

void onFileTilesSaveAsPNG(BuildContext context, Graphics graphics) async {
  FilePicker.platform.getDirectoryPath().then((directory) {
    if (directory != null) {
      List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
      String tileName = context.read<AppStateCubit>().state.tileName;
      int count = graphics.data.length ~/ (graphics.height * graphics.width);

      final png = tilesToPNG(graphics, colorSet, count);
      File("$directory/$tileName.png").writeAsBytesSync(png);
    }
  });
}

void onFileBackgroundSaveAsPNG(
  BuildContext context,
  Graphics background,
) async {
  FilePicker.platform.getDirectoryPath().then((directory) {
    if (directory != null) {
      MetaTile metaTile = context.read<MetaTileCubit>().state;
      List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
      String backgroundName = background.name;
      final png = backgroundToPNG(background, metaTile, colorSet);
      File("$directory/$backgroundName.png").writeAsBytesSync(png);
    }
  });
}

void _saveGraphics(
  Graphics graphics,
  String name,
  SourceConverter sourceConverter,
  BuildContext context,
) {
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
  Graphics graphics,
  String name,
  SourceConverter sourceConverter,
) async {
  String? directory = await FilePicker.platform.getDirectoryPath();

  if (directory != null) {
    File(
      "$directory/$name.h",
    ).writeAsString(sourceConverter.toHeader(graphics, name));
    File(
      "$directory/$name.c",
    ).writeAsString(sourceConverter.toSource(graphics, name));
  }

  return directory;
}
