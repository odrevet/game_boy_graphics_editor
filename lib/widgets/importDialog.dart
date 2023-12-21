import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/import.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';

import '../../models/sourceConverters/gbdk_tile_converter.dart';
import '../../models/sourceConverters/source_converter.dart';
import '../models/sourceConverters/gbdk_background_converter.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  bool compressedRLE = false;
  bool transpose = false;
  bool tile = true;
  String type = 'Source code';

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
                onImport(context, tile, type, transpose, compressedRLE);
              },
              icon: const Icon(Icons.file_open),
              label: const Text('File'),
            ),
            DropdownButton<String>(
              value: type,
              onChanged: (String? value) {
                setState(() {
                  type = value!;
                });

              },
              items: <String>['Source code', 'Binary']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            CheckboxListTile(
              title: const Text("Tile"),
              value: tile,
              onChanged: (bool? value) {
                setState(() {
                  tile = value!;
                });
              },
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
