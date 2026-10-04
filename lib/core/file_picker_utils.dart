import 'dart:convert';

import 'package:file_picker/file_picker.dart';

Future<List<PlatformFile>> selectFile(
    List<String> allowedExtensions, [
      bool allowMultiple = true,
    ]) async {
  if (allowMultiple) {
    return FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
  }

  final PlatformFile? file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  );
  return file == null ? [] : [file];
}

Future<String> readStringFromPlatformFile(PlatformFile platformFile) async =>
    utf8.decode(await platformFile.readAsBytes());

Future<List<int>> readBinFromPlatformFile(PlatformFile platformFile) =>
    platformFile.readAsBytes();