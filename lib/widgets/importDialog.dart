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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                onImport(context, parse, type, transpose, compressedRLE);
              },
              icon: const Icon(Icons.file_open),
              label: const Text('File'),
            ),
            Row(
              children: [
                const Expanded(child: Padding(
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
                const Expanded(child: Padding(
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
            )
          ],
        ),
      ),
    );
  }
}
