import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/converter_utils.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../cubits/app_state_cubit.dart';
import '../models/graphics/graphics.dart';
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
}

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
