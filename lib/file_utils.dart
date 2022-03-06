import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gbdk_graphic_editor/graphics.dart';

Future<void> saveFile(String content, allowedExtensions, [filename]) async {
  String? fileName = await FilePicker.platform
      .saveFile(allowedExtensions: allowedExtensions, fileName: filename);
  if (fileName != null) {
    File file = File(fileName);
    file.writeAsString(content);
  }
}

Future<void> saveToDirectory(Graphics graphics) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    File("$selectedDirectory/${graphics.name}.h")
        .writeAsString(graphics.toHeader());
    File("$selectedDirectory/${graphics.name}.c")
        .writeAsString(graphics.toSource());
  }
}

Future<String?> selectFolder() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['c'],
  );

  if (result != null) {
    late String source = "";
    if (kIsWeb) {
      Uint8List? bytes = result.files.single.bytes;
      source = String.fromCharCodes(bytes!);
    } else {
      File file = File(result.files.single.path!);
      source = await file.readAsString();
    }

    return source;
  }
  return null;
}
