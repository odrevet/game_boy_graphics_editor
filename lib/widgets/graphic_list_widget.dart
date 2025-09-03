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
import '../models/sourceConverters/gbdk_background_converter.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/states/graphics_state.dart';
import 'background/background_grid.dart';
import 'export_dialog.dart';
import 'graphic_form.dart';
import 'import_dialog.dart';

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
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text('Import'),
                              content: ImportDialog(),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Import Graphic from file'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddGraphicDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('New Graphic'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text('Export'),
                              content: ExportDialog(),
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
          final data = List.generate(dataLength, (index) => index % 256);

          // Determine type based on name
          GraphicsType type = GraphicsType.undefined;
          if (name.toLowerCase().endsWith('tiles')) {
            type = GraphicsType.tile;
          } else if (name.toLowerCase().endsWith('map')) {
            type = GraphicsType.map;
          }

          final graphic = Graphics(
            name: name,
            data: data,
            width: width,
            height: height,
            tileOrigin: tileOrigin,
            type: type,
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
          // Calculate new data length based on dimensions
          //final dataLength = width * height;
          // Create updated graphic with new dimensions but preserve some original data
          //final data = List.generate(
          //  dataLength,
          //  (i) => i < graphic.data.length ? graphic.data[i] : 0,
          //);
          final updatedGraphic = Graphics(
            name: name,
            data: graphic.data,
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

  bool _addMetaTile(Graphics graphics, BuildContext context, int tileOrigin) {
    bool hasLoaded = true;
    try {
      var data = GBDKTileConverter().combine(graphics.data);
      data = GBDKTileConverter().reorderFromSourceToCanvas(
        data,
        context.read<MetaTileCubit>().state.width,
        context.read<MetaTileCubit>().state.height,
      );

      // Add tile to the collection with the specified origin
      context.read<MetaTileCubit>().addTileAtOrigin(
        data,
        graphics.name,
        tileOrigin,
      );

      // Set the tile name for the app state
      context.read<AppStateCubit>().setTileName(graphics.name);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded "${graphics.name}" as tiles'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        // Keep debug print for development
        print("ERROR $e");
      }
      hasLoaded = false;

      // Show error message to user
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
      // Set selected tile to the first tile of the newly added graphic
      context.read<AppStateCubit>().setSelectedTileIndex(tileOrigin);
    }

    return hasLoaded;
  }

  void _showTilePreviewDialog(BuildContext context, graphic) {
    final controller = TextEditingController(
      text: graphic.tileOrigin.toString(),
    );
    var data = GBDKTileConverter().combine(graphic.data);
    data = GBDKTileConverter().reorderFromSourceToCanvas(
      data,
      context.read<MetaTileCubit>().state.width,
      context.read<MetaTileCubit>().state.height,
    );
    var preview = MetaTile(height: 8, width: 8, data: data);
    final tileCount =
        preview.data.length ~/ 64; //(preview.height * preview.width);

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

              // Show loading message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Loading "${graphic.name}" as tiles with origin $origin...',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );

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
      Background background = GBDKBackgroundConverter().fromGraphics(graphics);
      context.read<BackgroundCubit>().setWidth(background.width);
      context.read<BackgroundCubit>().setHeight(background.height);
      context.read<BackgroundCubit>().setData(background.data);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully loaded "${graphics.name}" as background'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
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

  void _showBackgroundPreviewDialog(BuildContext context, graphic) {
    Background preview = GBDKBackgroundConverter().fromGraphics(graphic);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Load ${graphic.name} as Background",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.8,
            height:
                MediaQuery.of(ctx).size.height *
                0.6, // Reduced height for actions
            child: BackgroundGrid(
              background: preview,
              tileOrigin: 0,
              //preview.tileOrigin,
              metaTile: context.read<MetaTileCubit>().state,
              showGrid: true,
              cellSize: 32,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _loadAsBackground(graphic, context);
              },
              child: const Text("Load"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataSize = (graphic.data.length / 1024).toStringAsFixed(1);
    final displayName = graphic.name.isNotEmpty
        ? graphic.name
        : 'Graphic ${index + 1}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dimensions: ${graphic.width} × ${graphic.height}'),
            Text('Data: ${dataSize}KB (${graphic.data.length} bytes)'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_circle_left),
              onSelected: (value) {
                if (value == 'tile') {
                  _showTilePreviewDialog(context, graphic);
                } else if (value == 'background') {
                  _showBackgroundPreviewDialog(context, graphic);
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
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit properties',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete Graphic',
            ),
          ],
        ),
      ),
    );
  }
}
