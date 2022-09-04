import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/download_stub.dart' if (dart.library.html) '../download.dart';
import '../models/file_utils.dart';

class SourceDisplay extends StatelessWidget {
  final String name;
  final List<int> tileData;

  const SourceDisplay({Key? key, required this.tileData, required this.name}) : super(key: key);

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
              //Clipboard.setData(ClipboardData(text: graphics.toHeader()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          kIsWeb
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.download),
                  onPressed: () => null, //download(graphics.toHeader(), headerFilename),
                )
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.save_as),
                  onPressed: () => null, //saveFile(graphics.toHeader(), ['.h'], headerFilename),
                ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(/*graphics.toHeader()*/ "",
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
              /*final snackBar = SnackBar(
                content: Text("Contents of ${graphics.name}.c copied into clipboard"),
              );
              Clipboard.setData(ClipboardData(text: graphics.toSource()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
            },
          ),
          kIsWeb
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.download),
                  onPressed: () => download(/*graphics.toSource()*/ "", sourceFilename),
                )
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.save_as),
                  onPressed: () => saveFile("" /*graphics.toSource()*/, ['.c'], sourceFilename),
                ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              "", //graphics.toSource(),
              style: const TextStyle(
                fontSize: fontSize,
              ),
            )),
      ],
    );
  }
}
