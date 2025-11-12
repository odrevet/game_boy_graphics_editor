import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/models/source_info.dart';

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
      downloadString(
        GBDKTileConverter().toHeader(graphics, graphics.name),
        '${graphics.name}.h',
      );
      downloadString(
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
      downloadString(
        GBDKBackgroundConverter().toHeader(graphics, graphics.name),
        '${graphics.name}.h',
      );
      downloadString(
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
    downloadBytes(bytes, '${name}.bin');
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
    downloadBytes(bytes, '$name.bin');
  } else {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      File("$directory/$name.bin").writeAsBytesSync(bytes);
    }
  }
}

void onFileTilesSaveAsPNG(BuildContext context, Graphics graphics) async {
  List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
  String tileName = context.read<AppStateCubit>().state.tileName;
  int count = graphics.data.length ~/ (graphics.height * graphics.width);

  final png = tilesToPNG(graphics, colorSet, count);

  if (kIsWeb) {
    downloadBytes(png, "$tileName.png");
  } else {
    FilePicker.platform.getDirectoryPath().then((directory) {
      if (directory != null) {
        File("$directory/$tileName.png").writeAsBytesSync(png);
      }
    });
  }
}

void onFileBackgroundSaveAsPNG(
  BuildContext context,
  Graphics background,
) async {
  MetaTile metaTile = context.read<MetaTileCubit>().state;
  List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
  String backgroundName = background.name;
  final png = backgroundToPNG(background, metaTile, colorSet);

  if (kIsWeb) {
    downloadBytes(png, "$backgroundName.png");
  } else {
    FilePicker.platform.getDirectoryPath().then((directory) {
      if (directory != null) {
        File("$directory/$backgroundName.png").writeAsBytesSync(png);
      }
    });
  }
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

/// Save updated source code - replaces the original array definition
Future<void> onFileSaveUpdatedSourceCode(
  BuildContext context,
  Graphics graphics,
  String updatedSource,
) async {
  try {
    // If we have a source path, offer to overwrite or save as new
    if (graphics.sourceInfo?.path != null &&
        graphics.sourceInfo!.format == SourceFormat.file) {
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Updated Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Do you want to overwrite the original file?'),
              const SizedBox(height: 16),
              Text(
                graphics.sourceInfo!.path!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Save As New'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (shouldOverwrite == null) return; // User cancelled

      if (shouldOverwrite) {
        // Overwrite the original file
        final file = File(graphics.sourceInfo!.path!);
        await file.writeAsString(updatedSource);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }
    }

    // Save as new file
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Updated Source Code',
      fileName: '${graphics.name}.c',
      type: FileType.custom,
      allowedExtensions: ['c', 'h', 'cpp', 'hpp'],
    );

    if (result == null) return; // User cancelled

    final file = File(result);
    await file.writeAsString(updatedSource);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
