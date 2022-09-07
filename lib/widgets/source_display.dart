import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/download_stub.dart' if (dart.library.html) '../download.dart';
import '../models/file_utils.dart';
import '../models/graphics/graphics.dart';
import '../models/sourceConverters/source_converter.dart';

class SourceDisplay extends StatelessWidget {
  final String name;
  final Function toSource;
  final String extension;

  const SourceDisplay({Key? key,
    required this.name,
    required this.toSource,
    required this.extension})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Text("$name$extension"),
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.copy),
            onPressed: () {
              final snackBar = SnackBar(
                content: Text("Contents of $name copied into clipboard"),
              );
              Clipboard.setData(ClipboardData(text: toSource()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          kIsWeb
              ? IconButton(
            iconSize: 18,
            icon: const Icon(Icons.download),
            onPressed: () => download(toSource(), name),
          )
              : IconButton(
            iconSize: 18,
            icon: const Icon(Icons.save_as),
            onPressed: () =>
                saveFile(toSource(), [extension], name),
          ),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              toSource(),
              style: const TextStyle(
                fontSize: 12,
              ),
            )),
      ],
    );
  }
}
