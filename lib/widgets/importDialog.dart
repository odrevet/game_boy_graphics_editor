import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/models/import.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  bool compressedRLE = false;
  bool transpose = false;
  String parse = 'Tile';
  String type = 'Auto';
  String url = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Data type"),
                )),
                DropdownButton<String>(
                  value: type,
                  onChanged: (String? value) {
                    setState(() {
                      type = value!;
                    });
                  },
                  items: <String>['Auto', 'Source code', 'Binary']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Parse as"),
                )),
                DropdownButton<String>(
                  value: parse,
                  onChanged: (String? value) {
                    setState(() {
                      parse = value!;
                    });
                  },
                  items: <String>['Tile', 'Background']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text("RLE decompress"),
              value: compressedRLE,
              enabled: !kIsWeb,   //TODO and if gbdk path is valid
              onChanged: (bool? value) {
                setState(() {
                  compressedRLE = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Transpose"),
              value: transpose,
              enabled: parse == 'Background',
              onChanged: (bool? value) {
                setState(() {
                  transpose = value!;
                });
              },
            ),
            Row(
              children: [
                const Text("Load from "),
                ElevatedButton.icon(
                  onPressed: () {
                    onImport(context, parse, type, transpose, compressedRLE);
                  },
                  icon: const Icon(Icons.file_open),
                  label: const Text('File'),
                ),
                const Text(" - or - "),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext alertDialogContext) =>
                            AlertDialog(
                                content: SizedBox(
                              width: 500,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'URL'),
                                        onChanged: (text) => setState(() {
                                              url = text;
                                            })),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      onImportHttp(context, parse, type,
                                          transpose, compressedRLE, url);
                                    },
                                    icon: const Icon(Icons.download),
                                    label: const Text('Load'),
                                  )
                                ],
                              ),
                            )));
                  },
                  icon: const Icon(Icons.http),
                  label: const Text('URL'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
