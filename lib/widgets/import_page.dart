import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/core/import_callbacks.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_preview_dialog.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../core/file_picker_utils.dart';
import '../core/load_callbacks.dart';
import '../cubits/app_state_cubit.dart';
import '../cubits/graphics_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/graphics/meta_tile.dart';
import '../models/source_parser.dart';
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
  bool loadOnImport = false;

  List<Graphics> graphicsPreview = [];
  List<Graphics> selectedGraphics = [];
  Map<Graphics, String> parseOptions = {};

  String _getDefaultParseOption(Graphics graphic) {
    final name = graphic.name.toLowerCase();
    if (name.endsWith('tiles')) {
      return 'Tiles';
    } else if (name.endsWith('map')) {
      return 'Background';
    } else {
      return 'Tiles';
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
                          // Get dimensions from cubit state for MetaTile conversion
                          final targetWidth = context
                              .read<MetaTileCubit>()
                              .state
                              .width;
                          final targetHeight = context
                              .read<MetaTileCubit>()
                              .state
                              .height;

                          // Convert graphics to their appropriate types based on parseOptions
                          final graphicsToImport = selectedGraphics.map((
                            graphic,
                          ) {
                            // Strip _map or _tiles from the name
                            String cleanedName = graphic.name;
                            if (cleanedName.endsWith('_map')) {
                              cleanedName = cleanedName.substring(
                                0,
                                cleanedName.length - 4,
                              );
                            } else if (cleanedName.endsWith('_tiles')) {
                              cleanedName = cleanedName.substring(
                                0,
                                cleanedName.length - 6,
                              );
                            }

                            final parseType =
                                parseOptions[graphic] ??
                                _getDefaultParseOption(graphic);
                            if (parseType == 'Background') {
                              final bg = Background.fromGraphics(graphic);
                              bg.name = cleanedName;
                              bg.sourceInfo = graphic.sourceInfo;

                              if (loadOnImport) {
                                loadBackground(bg, context);
                              }

                              return bg;
                            } else {
                              // For tiles, convert to MetaTile
                              final mt = MetaTile.fromGraphics(
                                graphic,
                                targetWidth: targetWidth,
                                targetHeight: targetHeight,
                              );
                              mt.name = cleanedName;
                              mt.sourceInfo = graphic.sourceInfo;

                              if (loadOnImport) {
                                loadMetaTile(mt, context, graphic.tileOrigin);
                              }

                              return mt;
                            }
                          }).toList();

                          context.read<GraphicsCubit>().addGraphics(
                            graphicsToImport,
                          );
                          Navigator.of(context).pop();
                          context
                              .read<AppStateCubit>()
                              .navigateToMemoryManager();
                        },
                  icon: const Icon(Icons.check),
                  label: Text('Import ${selectedGraphics.length} Selected'),
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
                  // Import Settings
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
                                  'Data type:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                      _getAvailableDataTypes().contains(type)
                                      ? type
                                      : _getAvailableDataTypes().first,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
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
                                  'Compression:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                                              .gbdkPathValid ||
                                          type != 'Binary'
                                      ? null
                                      : (value) {
                                          setState(() {
                                            compression = value!;
                                          });
                                        },
                                  items: ['none', 'rle', 'gb']
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

                          CheckboxListTile(
                            title: const Text(
                              'Load on import',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: const Text(
                              'Automatically load graphics after import',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: loadOnImport,
                            onChanged: (value) {
                              setState(() {
                                loadOnImport = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Import Source
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
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'File',
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.file_open, size: 16),
                                          SizedBox(width: 6),
                                          Text('File'),
                                        ],
                                      ),
                                    ),
                                    if (!kIsWeb)
                                      const DropdownMenuItem(
                                        value: 'URL',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.http, size: 16),
                                            SizedBox(width: 6),
                                            Text('URL'),
                                          ],
                                        ),
                                      ),
                                    const DropdownMenuItem(
                                      value: 'Clipboard',
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.content_paste, size: 16),
                                          SizedBox(width: 6),
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
                                  onPressed: _handleImport,
                                  icon: const Icon(Icons.arrow_upward),
                                  label: const Text('Read'),
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

            // Right side - Graphics list
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
                      if (graphicsPreview.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              graphicsPreview.clear();
                              selectedGraphics.clear();
                              parseOptions.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear All'),
                        ),
                      TextButton.icon(
                        onPressed: graphicsPreview.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  if (selectedGraphics.length ==
                                      graphicsPreview.length) {
                                    selectedGraphics.clear();
                                  } else {
                                    selectedGraphics = List.from(
                                      graphicsPreview,
                                    );
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
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: graphicsPreview.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              itemCount: graphicsPreview.length,
                              itemBuilder: (context, index) {
                                final graphic = graphicsPreview[index];
                                final isSelected = selectedGraphics.contains(
                                  graphic,
                                );
                                final currentParseOption =
                                    parseOptions[graphic] ??
                                    _getDefaultParseOption(graphic);

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedGraphics.add(graphic);
                                          } else {
                                            selectedGraphics.remove(graphic);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(
                                      graphic.name,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${graphic.width}×${graphic.height} px',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ToggleButtons(
                                          isSelected: [
                                            currentParseOption == 'Tiles',
                                            currentParseOption == 'Background',
                                          ],
                                          onPressed: (btnIndex) {
                                            setState(() {
                                              parseOptions[graphic] =
                                                  btnIndex == 0
                                                  ? 'Tiles'
                                                  : 'Background';
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          constraints: const BoxConstraints(
                                            minHeight: 32,
                                            minWidth: 36,
                                          ),
                                          children: const [
                                            Icon(Icons.image, size: 18),
                                            Icon(Icons.grid_4x4, size: 18),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          tooltip: 'Preview',
                                          onPressed: () {
                                            final parseType =
                                                parseOptions[graphic] ??
                                                _getDefaultParseOption(graphic);
                                            if (parseType == 'Background') {
                                              _showBackgroundPreviewDialog(
                                                context,
                                                graphic,
                                              );
                                            } else {
                                              _showTilePreviewDialog(
                                                context,
                                                graphic,
                                              );
                                            }
                                          },
                                          splashRadius: 20,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_attributes,
                                          ),
                                          tooltip: 'Properties',
                                          onPressed: () =>
                                              _showEditGraphicDialog(
                                                context,
                                                graphic,
                                              ),
                                          splashRadius: 20,
                                        ),
                                      ],
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
                                  ),
                                );
                              },
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No graphics imported yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the import button to load graphics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showTilePreviewDialog(BuildContext context, Graphics graphic) {
    final targetWidth = context.read<MetaTileCubit>().state.width;
    final targetHeight = context.read<MetaTileCubit>().state.height;

    var preview = MetaTile.fromGraphics(
      graphic,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    final tileCount = preview.data.length ~/ 64;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Preview ${graphic.name} as Tiles"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${graphic.width}×${graphic.height} px - $tileCount tiles",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Tile Preview",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      tileCount,
                      (index) => Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: MetaTileDisplay(
                              showGrid: false,
                              tileData: preview.getTileAtIndex(index),
                            ),
                          ),
                          Text("#$index", style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showBackgroundPreviewDialog(BuildContext context, Graphics graphics) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => BackgroundPreviewDialog(
        graphic: Background.fromGraphics(graphics),
        title: "Preview ${graphics.name} as Background",
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
    List<Graphics>? graphics;
    switch (importSource) {
      case 'File':
        final filePickerResult = await selectFile(['*']);
        if (filePickerResult != null) {
          graphics = await onImport(
            context,
            type,
            compression,
            filePickerResult,
          );

          // also search for properties and apply to matching graphic by name
          if (compression == 'none' && type != 'Binary') {
            for (var platformFile in filePickerResult.files) {
              final source = await readStringFromPlatformFile(platformFile);
              final parser = SourceParser();
              final defines = parser.readDefinesFromSource(source);

              // Apply defines to matching graphics
              if (graphics != null && defines.isNotEmpty) {
                for (var i = 0; i < graphics.length; i++) {
                  final graphic = graphics[i];
                  var graphicName = graphic.name;

                  // Remove _tiles or _map suffix if present
                  if (graphicName.endsWith('_tiles')) {
                    graphicName = graphicName.substring(
                      0,
                      graphicName.length - 6,
                    );
                  } else if (graphicName.endsWith('_map')) {
                    graphicName = graphicName.substring(
                      0,
                      graphicName.length - 4,
                    );
                  }

                  // Look for matching defines for this graphic
                  final widthKey = '${graphicName}_WIDTH';
                  final heightKey = '${graphicName}_HEIGHT';
                  final tileOriginKey = '${graphicName}_TILE_ORIGIN';

                  int? newWidth;
                  int? newHeight;
                  int? newTileOrigin;

                  if (defines.containsKey(widthKey)) {
                    newWidth = int.tryParse(defines[widthKey].toString());
                  }
                  if (defines.containsKey(heightKey)) {
                    newHeight = int.tryParse(defines[heightKey].toString());
                  }
                  if (defines.containsKey(tileOriginKey)) {
                    newTileOrigin = int.tryParse(
                      defines[tileOriginKey].toString(),
                    );
                  }

                  // Update graphic if any properties were found
                  if (newWidth != null ||
                      newHeight != null ||
                      newTileOrigin != null) {
                    graphics[i] = graphic.copyWith(
                      width: newWidth,
                      height: newHeight,
                      tileOrigin: newTileOrigin,
                    );
                  }
                }
              }
            }
          }
        }
        break;
      case 'URL':
        if (!kIsWeb) {
          _showUrlImportDialog(context);
          return;
        }
        break;
      case 'Clipboard':
        graphics = await onImportFromClipboard(context, type, compression);
        break;
    }

    if (graphics != null && graphics.isNotEmpty) {
      setState(() {
        graphicsPreview.addAll(graphics as Iterable<Graphics>);
        selectedGraphics.addAll(graphics as Iterable<Graphics>);
        for (final graphic in graphics!) {
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
                            if (elements != null && elements.isNotEmpty) {
                              setState(() {
                                graphicsPreview.addAll(elements);
                                selectedGraphics.addAll(elements);
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
