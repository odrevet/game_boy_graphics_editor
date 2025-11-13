import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/graphics_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/background.dart';
import '../models/graphics/graphics.dart';
import '../models/source_info.dart';
import '../models/states/graphics_state.dart';
import 'background/background_preview_dialog.dart';
import 'export_page.dart';
import 'graphic_form.dart';
import 'import_page.dart';

class GraphicsListWidget extends StatelessWidget {
  const GraphicsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearConfirmationDialog(context),
            tooltip: 'Clear All Graphics',
          ),
        ],
      ),
      body: BlocBuilder<GraphicsCubit, GraphicsState>(
        builder: (context, state) {
          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Graphics: ${state.graphics.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ImportPage(),
                            ),
                          ),

                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Import Graphics'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddGraphicDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('New Graphic'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ExportPage(),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Export Graphic'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Graphics list
              Expanded(
                child: state.graphics.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No graphics added yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Import or create graphic',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: state.graphics.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          context.read<GraphicsCubit>().reorderGraphics(
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (context, index) {
                          final graphic = state.graphics[index];
                          return _GraphicListTile(
                            key: ValueKey('graphic_$index'),
                            graphic: graphic,
                            index: index,
                            onEdit: () =>
                                _showEditGraphicDialog(context, index, graphic),
                            onDelete: () =>
                                _showDeleteConfirmationDialog(context, index),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddGraphicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => GraphicForm(
        title: 'Add New Graphic',
        onSubmit: (name, width, height, tileOrigin) {
          final dataLength =
              width * height; // Calculate data length based on dimensions
          final data = List.generate(dataLength, (index) => 0);

          final graphic = Graphics(
            name: name,
            data: data,
            width: width,
            height: height,
            tileOrigin: tileOrigin,
          );
          context.read<GraphicsCubit>().addGraphic(graphic);
        },
      ),
    );
  }

  void _showEditGraphicDialog(
    BuildContext context,
    int index,
    Graphics graphic,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => GraphicForm(
        title: 'Properties',
        initialName: graphic.name,
        initialWidth: graphic.width,
        initialHeight: graphic.height,
        initialTileOrigin: graphic.tileOrigin,
        onSubmit: (name, width, height, tileOrigin) {
          // Use copyWith to preserve the original type and all other properties
          final updatedGraphic = graphic.copyWith(
            name: name,
            width: width,
            height: height,
            tileOrigin: tileOrigin,
          );
          context.read<GraphicsCubit>().updateGraphicAt(index, updatedGraphic);
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    final graphic = context.read<GraphicsCubit>().state.graphics[index];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Graphic'),
        content: Text(
          'Are you sure you want to delete "${graphic.name.isNotEmpty ? graphic.name : 'Graphic ${index + 1}'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GraphicsCubit>().removeGraphicAt(index);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Graphics'),
        content: const Text(
          'Are you sure you want to remove all graphics? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GraphicsCubit>().clearGraphics();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _GraphicListTile extends StatelessWidget {
  final Graphics graphic;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GraphicListTile({
    Key? key,
    required this.graphic,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  // Helper to determine graphic type
  bool get _isBackground => graphic is Background;

  bool get _isMetaTile => graphic is MetaTile;

  // Get icon based on type
  IconData get _typeIcon {
    if (_isBackground) return Icons.grid_4x4;
    if (_isMetaTile) return Icons.image;
    return Icons.help_outline;
  }

  // Get type label
  String get _typeLabel {
    if (_isBackground) return 'Background';
    if (_isMetaTile) return 'Tiles';
    return 'Graphics';
  }

  String _getSourceFormatLabel(SourceFormat format) {
    switch (format) {
      case SourceFormat.file:
        return 'File';
      case SourceFormat.url:
        return 'URL';
      case SourceFormat.clipboard:
        return 'Clipboard';
    }
  }

  IconData _getSourceFormatIcon(SourceFormat format) {
    switch (format) {
      case SourceFormat.file:
        return Icons.insert_drive_file;
      case SourceFormat.url:
        return Icons.link;
      case SourceFormat.clipboard:
        return Icons.content_paste;
    }
  }

  String _getDataTypeLabel(DataType dataType) {
    switch (dataType) {
      case DataType.sourceCode:
        return 'Source';
      case DataType.binary:
        return 'Binary';
    }
  }

  bool _addMetaTile(Graphics graphics, BuildContext context, int tileOrigin) {
    bool hasLoaded = true;
    try {
      MetaTile metaTile;

      if (graphics is MetaTile) {
        metaTile = graphics;
      } else {
        final targetWidth = context.read<MetaTileCubit>().state.width;
        final targetHeight = context.read<MetaTileCubit>().state.height;
        metaTile = MetaTile.fromGraphics(
          graphics,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
      }

      context.read<MetaTileCubit>().addTileAtOrigin(metaTile, tileOrigin);
      context.read<AppStateCubit>().setTileName(graphics.name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded "${graphics.name}" as tiles'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("ERROR $e");
      }
      hasLoaded = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load "${graphics.name}" as tiles: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (hasLoaded) {
      context.read<AppStateCubit>().setSelectedTileIndex(tileOrigin);
    }

    return hasLoaded;
  }

  void _showTilePreviewDialog(BuildContext context, graphic) {
    final controller = TextEditingController(
      text: graphic.tileOrigin.toString(),
    );

    final targetWidth = context.read<MetaTileCubit>().state.width;
    final targetHeight = context.read<MetaTileCubit>().state.height;

    MetaTile preview;
    if (graphic is MetaTile) {
      preview = graphic;
    } else {
      preview = MetaTile.fromGraphics(
        graphic,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
    }

    final tileCount = preview.data.length ~/ 64;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Load ${graphic.name} as Tile"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Parameter",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Tile Origin"),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "This will add $tileCount tiles starting from the origin",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Preview",
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final origin = int.tryParse(controller.text) ?? 0;
              Navigator.of(dialogContext).pop();
              _addMetaTile(graphic, context, origin);
            },
            child: const Text("Add Tiles"),
          ),
        ],
      ),
    );
  }

  void _loadAsBackground(Graphics graphics, BuildContext context) {
    try {
      Background background;
      if (graphics is Background) {
        background = graphics;
      } else {
        background = Background.fromGraphics(graphics);
      }

      context.read<BackgroundCubit>().setWidth(background.width);
      context.read<BackgroundCubit>().setHeight(background.height);
      context.read<BackgroundCubit>().setData(background.data);
      context.read<BackgroundCubit>().setName(background.name);
      context.read<AppStateCubit>().setBackgroundName(background.name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded "${graphics.name}" as background'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load "${graphics.name}" as background: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildLoadButton(BuildContext context) {
    if (_isBackground) {
      return IconButton(
        icon: const Icon(Icons.arrow_circle_left),
        tooltip: 'Load as Background',
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => BackgroundPreviewDialog(
              graphic: graphic as Background,
              onLoad: () => _loadAsBackground(graphic, context),
            ),
          );
        },
      );
    }

    if (_isMetaTile) {
      return IconButton(
        icon: const Icon(Icons.arrow_circle_left),
        tooltip: 'Load as Tiles',
        onPressed: () => _showTilePreviewDialog(context, graphic),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.arrow_circle_left),
      tooltip: 'Load as...',
      onSelected: (value) {
        if (value == 'tile') {
          _showTilePreviewDialog(context, graphic);
        } else if (value == 'background') {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => BackgroundPreviewDialog(
              graphic: Background.fromGraphics(graphic),
              onLoad: () => _loadAsBackground(graphic, context),
            ),
          );
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'tile',
          child: ListTile(
            leading: Icon(Icons.image),
            title: Text("Load as Tiles"),
          ),
        ),
        const PopupMenuItem(
          value: 'background',
          child: ListTile(
            leading: Icon(Icons.grid_4x4),
            title: Text("Load as Background"),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    if (_isBackground) {
      return IconButton(
        icon: const Icon(Icons.arrow_downward),
        tooltip: 'Export as Background',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExportPage(graphic: graphic),
            ),
          );
        },
      );
    }

    if (_isMetaTile) {
      return IconButton(
        icon: const Icon(Icons.arrow_downward),
        tooltip: 'Export as Tiles',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExportPage(graphic: graphic),
            ),
          );
        },
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.arrow_downward),
      tooltip: 'Export as...',
      onSelected: (value) {
        if (value == 'tile') {
          final targetWidth = context.read<MetaTileCubit>().state.width;
          final targetHeight = context.read<MetaTileCubit>().state.height;

          var metatile = MetaTile.fromGraphics(
            graphic,
            targetWidth: targetWidth,
            targetHeight: targetHeight,
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExportPage(graphic: metatile),
            ),
          );
        } else if (value == 'background') {
          Background background = Background.fromGraphics(graphic);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExportPage(graphic: background),
            ),
          );
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'tile',
          child: ListTile(
            leading: Icon(Icons.image),
            title: Text("Export as Tile"),
          ),
        ),
        const PopupMenuItem(
          value: 'background',
          child: ListTile(
            leading: Icon(Icons.grid_4x4),
            title: Text("Export as Background"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataSize = (graphic.data.length / 1024).toStringAsFixed(1);
    final displayName = graphic.name.isNotEmpty
        ? graphic.name
        : 'Graphic ${index + 1}';
    final sourceInfo = graphic.sourceInfo;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left part - Icon and Content (50% of card width)
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  // Icon
                  Icon(
                    _typeIcon,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with name and type badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Dimensions and data info
                        Text(
                          'Dimensions: ${graphic.width} × ${graphic.height}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          'Data: ${dataSize}KB (${graphic.data.length} bytes)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),

                        // Source info if available
                        if (sourceInfo != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getSourceFormatIcon(sourceInfo.format),
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sourceInfo.path ??
                                      _getSourceFormatLabel(sourceInfo.format),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getDataTypeLabel(sourceInfo.dataType),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right part - Action buttons (expands to fill remaining space)
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLoadButton(context),
                      _buildExportButton(context),
                      IconButton(
                        icon: const Icon(Icons.edit_attributes),
                        onPressed: onEdit,
                        tooltip: 'Edit properties',
                        color: Colors.blue[700],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                        tooltip: 'Delete Graphic',
                        color: Colors.red[700],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}