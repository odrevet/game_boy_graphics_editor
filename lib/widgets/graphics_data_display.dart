import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbdk_graphic_editor/graphics.dart';

import '../file_utils.dart';

class GraphicsDataDisplay extends StatelessWidget {
  final Graphics graphics;

  const GraphicsDataDisplay({Key? key, required this.graphics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String headerFilename = "${graphics.name}.h";
    String sourceFilename = "${graphics.name}.c";
    return Column(
      children: [
        Row(children: [
          Text(headerFilename),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: graphics.toHeader())),
          ),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.save_as),
            onPressed: () =>
                saveFile(graphics.toHeader(), ['.h'], headerFilename),
          ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(graphics.toHeader())),
        const Divider(),
        Row(children: [
          Text("${graphics.name}.c"),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: graphics.toSource())),
          ),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.save_as),
            onPressed: () =>
                saveFile(graphics.toSource(), ['.c'], sourceFilename),
          ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(graphics.toSource())),
      ],
    );
  }
}
