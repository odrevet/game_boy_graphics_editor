import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/import_callbacks.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/graphics_cubit.dart';
import '../models/graphics/graphics.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  String compression = 'none';
  bool transpose = false;
  String previewAs = 'Tile';
  String type = 'Auto';
  String url = '';

  List<Graphics> graphicsPreview = [];
  List<Graphics> selectedGraphics = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data type
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Data type"),
                  ),
                ),
                DropdownButton<String>(
                  value: type,
                  onChanged: (String? value) {
                    setState(() {
                      type = value!;
                    });
                  },
                  items: <String>['Auto', 'Source code', 'Binary']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                ),
              ],
            ),
            // Preview as
            /*Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Parse as"),
                  ),
                ),
                DropdownButton<String>(
                  value: previewAs,
                  onChanged: (String? value) {
                    setState(() {
                      previewAs = value!;
                    });
                  },
                  items: <String>['Tile', 'Background'].map((v) {
                    IconData icon = v == 'Tile' ? Icons.image : Icons.grid_4x4;
                    return DropdownMenuItem<String>(
                      value: v,
                      child: Row(
                        children: [
                          Icon(icon),
                          const SizedBox(width: 8),
                          Text(v),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),*/
            // Compression
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Compression"),
                  ),
                ),
                DropdownButton<String>(
                  value: compression,
                  onChanged:
                      kIsWeb ||
                          !context.read<AppStateCubit>().state.gbdkPathValid
                      ? null
                      : (String? value) {
                          setState(() {
                            compression = value!;
                          });
                        },
                  items: <String>['none', 'rle', 'gb']
                      .map(
                        (v) =>
                            DropdownMenuItem<String>(value: v, child: Text(v)),
                      )
                      .toList(),
                ),
              ],
            ),
            // Transpose
            CheckboxListTile(
              title: const Text("Transpose"),
              value: transpose,
              enabled: previewAs == 'Background',
              onChanged: (bool? value) {
                setState(() {
                  transpose = value!;
                });
              },
            ),
            // File & URL buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final elements = await onImport(
                      context,
                      type,
                      transpose,
                      compression,
                    );
                    if (elements != null) {
                      setState(() {
                        graphicsPreview = elements;
                      });
                    }
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
                                              labelText: 'URL',
                                            ),
                                            onChanged: (text) => setState(() {
                                              url = text;
                                            }),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            onImportHttp(
                                              context,
                                              previewAs,
                                              type,
                                              transpose,
                                              url,
                                            );
                                          },
                                          icon: const Icon(Icons.download),
                                          label: const Text('Load'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        },
                  icon: const Icon(Icons.http),
                  label: const Text('URL'),
                ),
              ],
            ),
            // Graphics preview as selectable list
            if (graphicsPreview.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...graphicsPreview.map((graphic) {
                      bool isSelected = selectedGraphics.contains(graphic);
                      return ListTile(
                        title: Text(graphic.name),
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedGraphics.add(graphic);
                              } else {
                                selectedGraphics.remove(graphic);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedGraphics.remove(graphic);
                            } else {
                              selectedGraphics.add(graphic);
                            }
                          });
                        },
                      );
                    }),
                    ElevatedButton.icon(
                      onPressed: selectedGraphics.isEmpty
                          ? null
                          : () {
                              context.read<GraphicsCubit>().addGraphics(
                                selectedGraphics,
                              );
                              setState(() {
                                selectedGraphics.clear();
                              });
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Import Selected'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
