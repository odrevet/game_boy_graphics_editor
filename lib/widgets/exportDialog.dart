import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/models/export.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool compressedRLE = false;
  bool transpose = false;
  String type = 'Source code';
  String parse = 'Tile';

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
                  items: <String>['Source code', 'Binary', 'PNG']
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
                  child: Text("From"),
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
            /*CheckboxListTile(
              title: const Text("RLE compress"),
              value: compressedRLE,
              onChanged: (bool? value) {
                setState(() {
                  compressedRLE = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("Transpose"),
              value: transpose,
              onChanged: (bool? value) {
                setState(() {
                  transpose = value!;
                });
              },
            ),*/
            ElevatedButton.icon(
              onPressed: () {
                if (parse == 'Tile') {
                  if (type == 'Source code') {
                    onFileSaveAsSourceCode(context);  //WIP
                  } else if (type == 'Binary') {
                    onFileSaveAsBinTile(context);
                  } else if (type == 'PNG') {
                    onFileTilesSaveAsPNG(context);
                  }
                } else {
                  if (type == 'Source code') {
                    onFileSaveAsSourceCode(context);  // WIP
                  } else if (type == 'Binary') {
                    onFileSaveAsBinBackground(context);
                  } else if (type == 'PNG') {
                    onFileBackgroundSaveAsPNG(context);
                  }
                }
              },
              icon: const Icon(Icons.save_alt),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
