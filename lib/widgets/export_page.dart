import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/core/export_callbacks.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

import '../cubits/meta_tile_cubit.dart';
import '../models/source_parser.dart';
import '../models/source_info.dart';
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
  final SourceParser _sourceParser = SourceParser();

  Graphics? get graphic => widget.graphic;

  bool get canSaveUpdated {
    final graphics = _getGraphics();
    return graphics.sourceInfo != null &&
        graphics.sourceInfo!.dataType == DataType.sourceCode &&
        type == 'Source code';
  }

  Graphics _getGraphics() {
    if (widget.graphic != null) {
      return widget.graphic!;
    } else {
      if (parse == 'Tile') {
        return context.read<MetaTileCubit>().state;
      } else {
        return context.read<BackgroundCubit>().state;
      }
    }
  }

  void _handleSaveUpdated() {
    final graphics = _getGraphics();

    try {
      final updatedSource = _sourceParser.exportEdited(graphics);
      onFileSaveUpdatedSourceCode(context, graphics, updatedSource);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating source: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSaveNew() {
    final graphics = _getGraphics();

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
        onFileSaveAsSourceCode(context, parse, graphics);
      } else if (type == 'Binary') {
        onFileSaveAsBinBackground(context, graphics);
      } else {
        onFileBackgroundSaveAsPNG(context, graphics);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final graphics = _getGraphics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Graphics'),
        actions: [
          if (canSaveUpdated) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.update),
                label: const Text("Save Updated"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _handleSaveUpdated,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text("Save New"),
              onPressed: _handleSaveNew,
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
                        style: Theme.of(context).textTheme.titleMedium
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
                      if (canSaveUpdated) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoCard(graphics),
                      ],
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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

  Widget _buildInfoCard(Graphics graphics) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Update Mode Available',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Array name: ${graphics.name}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          if (graphics.sourceInfo?.path != null)
            Text(
              'Source: ${graphics.sourceInfo!.path}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text(
            '"Save Updated" will replace the original array definition with your changes.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
