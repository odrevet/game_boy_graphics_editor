import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_tile_converter.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_converter.dart';

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

Future<String?> saveBinToDirectory(
    Graphics graphics, String name) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    List<int> bytes = GBDKTileConverter().toBin(graphics).codeUnits;
    File("$selectedDirectory/$name.bin")
        .writeAsBytesSync(bytes);
  }

  return selectedDirectory;
}

Future<FilePickerResult?> selectFile(List<String> allowedExtensions) async =>
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

Future<String> readBytes(FilePickerResult filePickerResult) async {
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
