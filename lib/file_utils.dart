import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> saveFile(String content) async {
  String? fileName =
      await FilePicker.platform.saveFile(allowedExtensions: [".c"]);
  if (fileName != null) {
    File file = File(fileName);
    file.writeAsString(content);
    //file.writeAsString(tiles.toSource());
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
