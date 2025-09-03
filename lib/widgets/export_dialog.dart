import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/export_callbacks.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/widgets/source_display.dart';

import '../cubits/graphics_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/states/graphics_state.dart';

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
    return BlocBuilder<GraphicsCubit, GraphicsState>(
      builder: (context, state) {
        return Dialog(
          child: SizedBox(
            width: 900,
            height: 600,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // preview panel
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          padding: const EdgeInsets.all(16),
                          child: ExportPreview(type, parse),
                        ),
                      ),

                      const VerticalDivider(width: 1),
                      // settings panel
                      Expanded(
                        flex: 1,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildDropdown(
                              label: "Data type",
                              value: type,
                              items: const ['Source code', 'Binary', 'PNG'],
                              onChanged: (v) => setState(() => type = v!),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: "From",
                              value: parse,
                              items: [
                                'Tile',
                                'Background',
                                ...state.graphics.map((g) => g.name),
                              ],
                              onChanged: (v) => setState(() => parse = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt),
                        label: const Text("Save"),
                        onPressed: () {
                          if (parse == 'Tile') {
                            if (type == 'Source code') {
                              onFileSaveAsSourceCode(context, parse);
                            } else if (type == 'Binary') {
                              onFileSaveAsBinTile(context);
                            } else {
                              onFileTilesSaveAsPNG(context);
                            }
                          } else {
                            if (type == 'Source code') {
                              onFileSaveAsSourceCode(context, parse);
                            } else if (type == 'Binary') {
                              onFileSaveAsBinBackground(context);
                            } else {
                              onFileBackgroundSaveAsPNG(context);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
      ],
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
        header = GBDKTileConverter().toHeader(
          context.read<MetaTileCubit>().state,
          name,
        );
        source = GBDKTileConverter().toSource(
          context.read<MetaTileCubit>().state,
          name,
        );
        name = context.read<AppStateCubit>().state.tileName;
      } else if (parse == 'Background') {
        header = GBDKBackgroundConverter().toHeader(
          context.read<BackgroundCubit>().state,
          name,
        );
        source = GBDKBackgroundConverter().toSource(
          context.read<BackgroundCubit>().state,
          name,
        );
        name = context.read<AppStateCubit>().state.backgroundName;
      }

      return Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SourceDisplay(source: header, name: name, extension: '.h'),
                const SizedBox(height: 12),
                SourceDisplay(source: source, name: name, extension: '.c'),
              ],
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Text(
        "No preview available",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
