import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/import_callbacks.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/graphics_cubit.dart';
import '../models/graphics/graphics.dart';
import 'graphic_form.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String compression = 'none';
  String previewAs = 'Tile';
  String type = 'Auto';
  String importSource = 'File';
  String url = '';

  List<Graphics> graphicsPreview = [];
  List<Graphics> selectedGraphics = [];
  Map<Graphics, String> parseOptions = {};

  String _getDefaultParseOption(Graphics graphic) {
    final name = graphic.name.toLowerCase();

    if (name.endsWith('tiles') || name.endsWith('tile')) {
      return 'Tile';
    } else if (name.endsWith('map')) {
      return 'Background';
    } else {
      return 'Graphics';
    }
  }

  List<String> _getAvailableDataTypes() {
    if (importSource == 'Clipboard') {
      return ['Source code'];
    }
    return ['Auto', 'Source code', 'Binary'];
  }

  void _onImportSourceChanged(String? value) {
    setState(() {
      importSource = value!;
      if (importSource == 'Clipboard' && type != 'Source code') {
        type = 'Source code';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Graphics'),
        actions: [
          if (graphicsPreview.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: selectedGraphics.isEmpty
                      ? null
                      : () {
                    context.read<GraphicsCubit>().addGraphics(
                      selectedGraphics,
                    );
                    Navigator.of(context).pop();
                    context.read<AppStateCubit>().navigateToMemoryManager();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Import ${selectedGraphics.length} Selected',
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
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
                                  initialValue: _getAvailableDataTypes().contains(type)
                                      ? type
                                      : _getAvailableDataTypes().first,
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
                                  items: _getAvailableDataTypes()
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
                                  onChanged: kIsWeb ||
                                      !context
                                          .read<AppStateCubit>()
                                          .state
                                          .gbdkPathValid ||
                                      type != 'Binary'
                                      ? null
                                      : (String? value) {
                                    setState(() {
                                      compression = value!;
                                    });
                                  },
                                  items: <String>['none', 'rle', 'gb']
                                      .map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Import type dropdown and button
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: importSource,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: _onImportSourceChanged,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'File',
                                      child: Row(
                                        children: [
                                          Icon(Icons.file_open, size: 16),
                                          SizedBox(width: 8),
                                          Text('File'),
                                        ],
                                      ),
                                    ),
                                    if (!kIsWeb)
                                      const DropdownMenuItem(
                                        value: 'URL',
                                        child: Row(
                                          children: [
                                            Icon(Icons.http, size: 16),
                                            SizedBox(width: 8),
                                            Text('URL'),
                                          ],
                                        ),
                                      ),
                                    const DropdownMenuItem(
                                      value: 'Clipboard',
                                      child: Row(
                                        children: [
                                          Icon(Icons.content_paste, size: 16),
                                          SizedBox(width: 8),
                                          Text('Clipboard'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleImport(),
                                  icon: const Icon(Icons.arrow_upward),
                                  label: const Text('Import'),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: graphicsPreview.isEmpty
                            ? null
                            : () {
                          setState(() {
                            if (selectedGraphics.length ==
                                graphicsPreview.length) {
                              selectedGraphics.clear();
                            } else {
                              selectedGraphics =
                                  List.from(graphicsPreview);
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
                      child: graphicsPreview.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha:0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No graphics imported yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha:0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use the import button to load graphics',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha:0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${selectedGraphics.length} of ${graphicsPreview.length} selected',
                                  style:
                                  Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: graphicsPreview.length,
                              itemBuilder: (context, index) {
                                final graphic = graphicsPreview[index];
                                final isSelected =
                                selectedGraphics.contains(graphic);

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
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_attributes),
                                    tooltip: 'Properties',
                                    onPressed: () =>
                                        _showEditGraphicDialog(
                                            context, graphic),
                                    splashRadius: 20,
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
    );
  }

  void _showEditGraphicDialog(BuildContext context, Graphics graphic) {
    showDialog(
      context: context,
      builder: (dialogContext) => GraphicForm(
        title: 'Properties',
        initialName: graphic.name,
        initialWidth: graphic.width,
        initialHeight: graphic.height,
        initialTileOrigin: graphic.tileOrigin,
        onSubmit: (name, width, height, tileOrigin) {
          setState(() {
            graphic.name = name;
            graphic.width = width;
            graphic.height = height;
            graphic.tileOrigin = tileOrigin;
          });
        },
      ),
    );
  }

  void _handleImport() async {
    List<Graphics>? elements;

    switch (importSource) {
      case 'File':
        elements = await onImport(context, type, compression);
        break;
      case 'URL':
        if (!kIsWeb) {
          _showUrlImportDialog(context);
          return;
        }
        break;
      case 'Clipboard':
        elements = await onImportFromClipboard(context, type, compression);
        break;
    }

    if (elements != null) {
      setState(() {
        graphicsPreview = elements!;
        selectedGraphics = List.from(elements);
        for (final graphic in elements) {
          parseOptions[graphic] ??= _getDefaultParseOption(graphic);
        }
      });
    }
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
                          selectedGraphics = List.from(elements);
                          for (final graphic in elements) {
                            parseOptions[graphic] ??=
                                _getDefaultParseOption(graphic);
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.arrow_upward),
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