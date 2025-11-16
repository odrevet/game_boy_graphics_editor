import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/core/converter_utils.dart';
import 'package:game_boy_graphics_editor/models/source_parser.dart';
import 'package:game_boy_graphics_editor/models/source_info.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../cubits/app_state_cubit.dart';
import '../models/graphics/graphics.dart';
import 'file_picker_utils.dart';

Future<List<Graphics>?> onImportHttp(
  BuildContext context,
  String parse,
  String type,
  String url,
) async {
  Uri uriObject = Uri.parse(url);

  if (type == 'Auto') {
    type = resolveType(uriObject.path);
  }

  if (type == 'Binary') {
    final bin = await http.readBytes(uriObject);
    List<int> data = convertBytesToDecimals(bin);
    String filename = uriObject.pathSegments.isNotEmpty
        ? uriObject.pathSegments.last
        : "from bin";

    final sourceInfo = SourceInfo(
      format: SourceFormat.url,
      dataType: DataType.binary,
      path: url,
      content: bin,
    );

    var graphics = Graphics(name: filename, data: data, sourceInfo: sourceInfo);
    return [graphics];
  } else {
    final source = await http.read(uriObject);
    final parser = SourceParser();
    final graphicsElements = parser.parseAllArrays(source);

    // Create single SourceInfo shared by all graphics from this source
    final sourceInfo = SourceInfo(
      format: SourceFormat.url,
      dataType: DataType.sourceCode,
      path: url,
      content: source,
    );

    // All graphics reference the same SourceInfo instance
    for (var graphic in graphicsElements) {
      graphic.sourceInfo = sourceInfo;
    }

    return graphicsElements;
  }
}

Future<List<Graphics>?> onImport(
  BuildContext context,
  String type,
  String compression,
  FilePickerResult filePickerResult,
) async {
  // Handle multiple files
  final allGraphics = <Graphics>[];

  for (var platformFile in filePickerResult.files) {
    final filePath = platformFile.path!;
    final fileName = platformFile.name;

    String currentType = type;
    if (currentType == 'Auto') {
      currentType = resolveType(fileName);
    }

    if (currentType == 'Binary') {
      List<int> data;
      List<int> originalContent;

      if (compression != 'none') {
        // From binary with compression
        originalContent = File(filePath).readAsBytesSync();
        data = _decompress(filePath, compression, context);

        if (data.isNotEmpty) {
          final sourceInfo = SourceInfo(
            format: SourceFormat.file,
            dataType: DataType.binary,
            path: filePath,
            content: originalContent,
          );

          var graphics = Graphics(
            name: fileName,
            data: data,
            sourceInfo: sourceInfo,
          );
          allGraphics.add(graphics);
        }
      } else {
        // From binary
        final bin = await readBinFromPlatformFile(platformFile);
        data = convertBytesToDecimals(bin);

        final sourceInfo = SourceInfo(
          format: SourceFormat.file,
          dataType: DataType.binary,
          path: filePath,
          content: bin,
        );

        var graphics = Graphics(
          name: fileName,
          data: data,
          sourceInfo: sourceInfo,
        );
        allGraphics.add(graphics);
      }
    } else {
      // From source
      final source = await readStringFromPlatformFile(platformFile);
      final parser = SourceParser();
      final graphicsElements = parser.parseAllArrays(source);

      // Create single SourceInfo shared by all graphics from this source file
      final sourceInfo = SourceInfo(
        format: SourceFormat.file,
        dataType: DataType.sourceCode,
        path: filePath,
        content: source,
      );

      // All graphics from the same file reference the same SourceInfo instance
      for (var graphic in graphicsElements) {
        graphic.sourceInfo = sourceInfo;
      }

      allGraphics.addAll(graphicsElements);
    }
  }

  return allGraphics.isEmpty ? null : allGraphics;
}

Future<List<Graphics>?> onImportFromClipboard(
  BuildContext context,
  String type,
  String compression,
) async {
  ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  if (type == 'Auto') {
    type = 'Source';
  }

  if (clipboardData == null || clipboardData.text!.isEmpty) {
    return null;
  }

  // From source
  final source = clipboardData.text!;
  final parser = SourceParser();
  final graphicsElements = parser.parseAllArrays(source);

  // Create single SourceInfo shared by all graphics from clipboard
  final sourceInfo = SourceInfo(
    format: SourceFormat.clipboard,
    dataType: DataType.sourceCode,
    path: null, // No path for clipboard
    content: source,
  );

  // All graphics from clipboard reference the same SourceInfo instance
  for (var graphic in graphicsElements) {
    graphic.sourceInfo = sourceInfo;
  }

  return graphicsElements;
}

String resolveType(String path) {
  String extension = p.extension(path);
  if (extension == '.c' || extension == '.h') {
    return 'Source code';
  } else {
    return 'Binary';
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
