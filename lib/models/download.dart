import 'dart:convert';

import 'package:web/web.dart';

void downloadString(String content, String downloadName) {
  final base64 = base64Encode(content.codeUnits);
  final anchor = HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$base64'
    ..target = '_blank'
    ..download = downloadName;

  document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

void downloadBytes(List<int> bytes, String downloadName) {
  final base64 = base64Encode(bytes);
  final anchor = HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$base64'
    ..target = '_blank'
    ..download = downloadName;

  document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
