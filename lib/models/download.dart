import 'dart:convert';

import 'package:web/web.dart';

void download(String content, String downloadName) {
  final base64 = base64Encode(content.codeUnits);
  final anchor = HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$base64'
    ..target = '_blank'
    ..download = downloadName;

  document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
