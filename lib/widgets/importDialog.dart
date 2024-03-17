import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/import.dart';

import '../cubits/app_state_cubit.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  String compression = 'none';
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
                    IconData icon = Icons.error;
                    if (value == 'Tile') {
                      icon = Icons.image; // Choose appropriate icon for 'Tile'
                    } else if (value == 'Background') {
                      icon = Icons
                          .grid_4x4; // Choose appropriate icon for 'Background'
                    }

                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(icon), // Icon widget
                          const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
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
                  child: Text("Compression"),
                )),
                DropdownButton<String>(
                  value: compression,
                  onChanged: kIsWeb ||
                          !context.read<AppStateCubit>().state.gbdkPathValid
                      ? null
                      : (String? value) {
                          setState(() {
                            compression = value!;
                          });
                        },
                  items: <String>['none', 'rle', 'gb']
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
                ElevatedButton.icon(
                  onPressed: () {
                    onImport(context, parse, type, transpose, compression);
                  },
                  icon: const Icon(Icons.file_open),
                  label: const Text('File'),
                ),
                const Text(" | "),
                ElevatedButton.icon(
                  onPressed: kIsWeb
                      ? null
                      : () {
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
                                                transpose, url);
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
