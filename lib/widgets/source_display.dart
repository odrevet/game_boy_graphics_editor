import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/download_stub.dart' if (dart.library.html) '../download.dart';
import '../models/file_utils.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/gbdk_converter.dart';
import '../models/sourceConverters/source_converter.dart';

class SourceDisplay extends StatelessWidget {
  final String name;
  final Graphics graphics;
  final SourceConverter sourceConverter;

  const SourceDisplay({Key? key, required this.graphics, required this.name, required this.sourceConverter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String headerFilename = "$name.h";
    String sourceFilename = "$name.c";
    const double fontSize = 12;

    return Column(
      children: [
        Row(children: [
          Text(headerFilename),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () {
              final snackBar = SnackBar(
                content: Text("Contents of $headerFilename copied into clipboard"),
              );
              Clipboard.setData(ClipboardData(text: sourceConverter.toHeader(graphics, name)));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          kIsWeb
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.download),
                  onPressed: () => download(sourceConverter.toHeader(graphics, name), headerFilename),
                )
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.save_as),
                  onPressed: () => saveFile(sourceConverter.toHeader(graphics, name), ['.h'], headerFilename),
                ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(sourceConverter.toHeader(graphics, name),
                style: const TextStyle(
                  fontSize: fontSize,
                ))),
        const Divider(),
        Row(children: [
          Text("$name.c"),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () {
              final snackBar = SnackBar(
                content: Text("Contents of $name.c copied into clipboard"),
              );
              Clipboard.setData(ClipboardData(text: sourceConverter.toSource(graphics, name)));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          kIsWeb
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.download),
                  onPressed: () => download(sourceConverter.toSource(graphics, name), sourceFilename),
                )
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.save_as),
                  onPressed: () => saveFile(sourceConverter.toSource(graphics, name), ['.c'], sourceFilename),
                ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              sourceConverter.toSource(graphics, name),
              style: const TextStyle(
                fontSize: fontSize,
              ),
            )),
      ],
    );
  }
}
