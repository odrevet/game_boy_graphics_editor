import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/download_stub.dart'
    if (dart.library.html) '../models/download.dart';

class SourceDisplay extends StatelessWidget {
  final String name;
  final String source;
  final String extension;

  const SourceDisplay(
      {super.key,
      required this.name,
      required this.source,
      required this.extension});

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
              Clipboard.setData(ClipboardData(text: source));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          kIsWeb
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.download),
                  onPressed: () => download(source, name),
                )
              : IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.save_as),
                  onPressed: () async {
                    var fileName = await FilePicker.platform.saveFile(
                        allowedExtensions: [extension], fileName: name);
                    if (fileName != null) {
                      var file = File(fileName);
                      file.writeAsString(source);
                    }
                  }),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              source,
              style: const TextStyle(
                fontSize: 12,
              ),
            )),
      ],
    );
  }
}
