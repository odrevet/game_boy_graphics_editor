import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void downloadString(String content, String filename) {
  downloadBytes(utf8.encode(content), filename);
}

void downloadBytes(List<int> bytes, String filename) {
  final blob = web.Blob([Uint8List.fromList(bytes).toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}