import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/export_callbacks.dart';
import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

import '../cubits/meta_tile_cubit.dart';
import 'export_preview.dart';

class ExportDialog extends StatefulWidget {
  final Graphics? graphic;

  const ExportDialog({super.key, this.graphic});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool compressedRLE = false;
  bool transpose = false;
  String type = 'Source code';
  String parse = 'Tile';
  late bool displayFrom = widget.graphic == null;

  // Access the graphic parameter using widget.graphic
  Graphics? get graphic => widget.graphic;

  @override
  Widget build(BuildContext context) {
    Graphics graphics;
    if (widget.graphic != null) {
      graphics = widget.graphic!;
    } else {
      if (parse == 'Tile') {
        graphics = context.read<MetaTileCubit>().state;
      } else {
        graphics = context.read<BackgroundCubit>().state;
      }
    }

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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.all(16),
                      child: ExportPreview(graphics, type),
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
                        if (displayFrom)
                          _buildDropdown(
                            label: "From",
                            value: parse,
                            items: ['Tile', 'Background'],
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
                          onFileSaveAsSourceCode(context, parse, graphics);
                        } else if (type == 'Binary') {
                          onFileSaveAsBinTile(context, graphics);
                        } else {
                          onFileTilesSaveAsPNG(context, graphics);
                        }
                      } else {
                        if (type == 'Source code') {
                          onFileSaveAsSourceCode(
                            context,
                            parse,
                            graphics,
                          );
                        } else if (type == 'Binary') {
                          onFileSaveAsBinBackground(
                            context,
                            graphics,
                          );
                        } else {
                          onFileBackgroundSaveAsPNG(
                            context,
                            graphics,
                          );
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