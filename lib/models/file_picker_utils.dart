import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<FilePickerResult?> selectFile(List<String> allowedExtensions, [bool allowMultiple = true]) async =>
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
    );

Future<String> readStringFromFilePickerResult(FilePickerResult filePickerResult) async {
  if (kIsWeb) {
    Uint8List? bytes = filePickerResult.files.single.bytes;
    return String.fromCharCodes(bytes!);
  } else {
    File file = File(filePickerResult.files.single.path!);
    return await file.readAsString();
  }
}

Future<String> readStringFromPlatformFile(PlatformFile platformFile) async {
  if (kIsWeb) {
    Uint8List? bytes = platformFile.bytes;
    return String.fromCharCodes(bytes!);
  } else {
    File file = File(platformFile.path!);
    return await file.readAsString();
  }
}

Future<List<int>> readBinFromPlatformFile(PlatformFile platformFile) async {
  if (kIsWeb) {
    return platformFile.bytes!;
  } else {
    File file = File(platformFile.path!);
    return await file.readAsBytes();
  }
}
