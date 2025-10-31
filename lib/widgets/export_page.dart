import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/export_callbacks.dart';
import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

import '../cubits/meta_tile_cubit.dart';
import 'export_preview.dart';

class ExportPage extends StatefulWidget {
  final Graphics? graphic;

  const ExportPage({super.key, this.graphic});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool compressedRLE = false;
  bool transpose = false;
  String type = 'Source code';
  String parse = 'Tile';
  late bool displayFrom = widget.graphic == null;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Graphics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text("Export"),
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
                // Optionally close after export
                // Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Settings panel
            SizedBox(
              width: 400,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Export Settings',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      _buildDropdown(
                        label: "Data type:",
                        value: type,
                        items: const ['Source code', 'Binary', 'PNG'],
                        onChanged: (v) => setState(() => type = v!),
                      ),
                      const SizedBox(height: 16),
                      if (displayFrom)
                        _buildDropdown(
                          label: "From:",
                          value: parse,
                          items: ['Tile', 'Background'],
                          onChanged: (v) => setState(() => parse = v!),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Right side - Preview panel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        padding: const EdgeInsets.all(16),
                        child: ExportPreview(graphics, type),
                      ),
                    ),
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
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}