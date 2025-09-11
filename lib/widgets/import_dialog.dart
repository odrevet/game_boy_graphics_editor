import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/import_callbacks.dart';
import 'package:flutter/services.dart';

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
  String previewAs = 'Tile';
  String type = 'Auto';
  String url = '';

  List<Graphics> graphicsPreview = [];
  List<Graphics> selectedGraphics = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 900, // Increased width to accommodate side-by-side layout
      height: 700,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content row with settings on left and preview on right
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Settings and Import Source
                SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Settings Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Settings',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),

                              // Data type
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 120,
                                    child: Text(
                                      "Data type:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: type,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          type = value!;
                                        });
                                      },
                                      items:
                                          <String>[
                                                'Auto',
                                                'Source code',
                                                'Binary',
                                              ]
                                              .map(
                                                (v) => DropdownMenuItem(
                                                  value: v,
                                                  child: Text(v),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Compression
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 120,
                                    child: Text(
                                      "Compression:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: compression,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged:
                                          kIsWeb ||
                                              !context
                                                  .read<AppStateCubit>()
                                                  .state
                                                  .gbdkPathValid
                                          ? null
                                          : (String? value) {
                                              setState(() {
                                                compression = value!;
                                              });
                                            },
                                      items: <String>['none', 'rle', 'gb']
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Import Source Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Source',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),

                              // File button
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final elements = await onImport(
                                          context,
                                          type,
                                          compression,
                                        );
                                        if (elements != null) {
                                          setState(() {
                                            graphicsPreview = elements;
                                            // Auto-select all imported graphics
                                            selectedGraphics = List.from(
                                              elements,
                                            );
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.file_open),
                                      label: const Text('Import from File'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // URL button
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: kIsWeb
                                          ? null
                                          : () {
                                              _showUrlImportDialog(context);
                                            },
                                      icon: const Icon(Icons.http),
                                      label: const Text('Import from URL'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Clipboard button
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final elements =
                                            await onImportFromClipboard(
                                              context,
                                              type,
                                              compression,
                                            );
                                        if (elements != null) {
                                          setState(() {
                                            graphicsPreview = elements;
                                            // Auto-select all imported graphics
                                            selectedGraphics = List.from(
                                              elements,
                                            );
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.content_paste),
                                      label: const Text(
                                        'Import from Clipboard',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right side - Graphics preview section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Found ${graphicsPreview.length} graphic(s)',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (selectedGraphics.length ==
                                    graphicsPreview.length) {
                                  selectedGraphics.clear();
                                } else {
                                  selectedGraphics = List.from(graphicsPreview);
                                }
                              });
                            },
                            icon: Icon(
                              selectedGraphics.length == graphicsPreview.length
                                  ? Icons.deselect
                                  : Icons.select_all,
                            ),
                            label: Text(
                              selectedGraphics.length == graphicsPreview.length
                                  ? 'Deselect All'
                                  : 'Select All',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Scrollable graphics list
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${selectedGraphics.length} of ${graphicsPreview.length} selected',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: graphicsPreview.length,
                                  itemBuilder: (context, index) {
                                    final graphic = graphicsPreview[index];
                                    final isSelected = selectedGraphics
                                        .contains(graphic);

                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        graphic.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
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
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom import action (full width)
          if (graphicsPreview.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedGraphics.isEmpty
                    ? null
                    : () {
                        context.read<GraphicsCubit>().addGraphics(
                          selectedGraphics,
                        );
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.add),
                label: Text(
                  selectedGraphics.isEmpty
                      ? 'Select graphics to import'
                      : 'Import ${selectedGraphics.length} Selected Graphics',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUrlImportDialog(BuildContext context) {
    String dialogUrl = '';

    showDialog(
      context: context,
      builder: (BuildContext alertDialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Import from URL'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (text) => setDialogState(() {
                    dialogUrl = text;
                  }),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: dialogUrl.isEmpty
                        ? null
                        : () async {
                            Navigator.of(alertDialogContext).pop();
                            final elements = await onImportHttp(
                              context,
                              previewAs,
                              type,
                              dialogUrl,
                            );
                            if (elements != null) {
                              setState(() {
                                graphicsPreview = elements;
                                // Auto-select all imported graphics
                                selectedGraphics = List.from(elements);
                              });
                            }
                          },
                    icon: const Icon(Icons.download),
                    label: const Text('Import from URL'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
