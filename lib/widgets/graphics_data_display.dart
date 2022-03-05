import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbdk_graphic_editor/graphics.dart';

class GraphicsDataDisplay extends StatelessWidget {
  final Graphics graphics;

  const GraphicsDataDisplay({Key? key, required this.graphics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Text("${graphics.name}.h"),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: graphics.toHeader())),
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
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(graphics.toSource())),
      ],
    );
  }
}
