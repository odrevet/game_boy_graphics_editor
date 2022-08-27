import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void download(String content, String downloadName) {
  final base64 = base64Encode(content.codeUnits);
  final anchor = html.AnchorElement(href: 'data:application/octet-stream;base64,$base64')
    ..target = 'blank';
  anchor.download = downloadName;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
