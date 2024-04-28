import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/export_callbacks.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/widgets/source_display.dart';

import '../cubits/meta_tile_cubit.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                          onFileSaveAsSourceCode(context, parse);
                        } else if (type == 'Binary') {
                          onFileSaveAsBinTile(context);
                        } else if (type == 'PNG') {
                          onFileTilesSaveAsPNG(context);
                        }
                      } else {
                        if (type == 'Source code') {
                          onFileSaveAsSourceCode(context, parse);
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
            const VerticalDivider(),
            // Preview
            ExportPreview(type, parse)
          ],
        ),
      ),
    );
  }
}

class ExportPreview extends StatelessWidget {
  final String type;
  final String parse;

  const ExportPreview(this.type, this.parse, {super.key});

  @override
  Widget build(BuildContext context) {
    if (type == 'Source code') {
      var name = '';
      var header = '';
      var source = '';

      if (parse == 'Tile') {
        header = GBDKTileConverter()
            .toHeader(context.read<MetaTileCubit>().state, name);
        source = GBDKTileConverter()
            .toSource(context.read<MetaTileCubit>().state, name);
        name = context.read<AppStateCubit>().state.tileName;
      } else if (parse == 'Background') {
        header = GBDKBackgroundConverter()
            .toHeader(context.read<BackgroundCubit>().state, name);
        source = GBDKBackgroundConverter()
            .toSource(context.read<BackgroundCubit>().state, name);
        name = context.read<AppStateCubit>().state.backgroundName;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SourceDisplay(
            source: header,
            name: name,
            extension: '.h',
          ),
          SourceDisplay(
            source: source, name: name, extension: '.c',
            //graphics: metaTile,
          ),
        ],
      );
    }

    return const Text("no preview");
  }
}
