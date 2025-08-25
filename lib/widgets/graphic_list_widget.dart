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
import 'import_dialog.dart';

class GraphicsListWidget extends StatelessWidget {
  const GraphicsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphics Manager'),
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
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Error banner
              if (state.error != null)
                Container(
                  width: double.infinity,
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      /*IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.read<GraphicsCubit>().clearError(),
                      ),*/
                    ],
                  ),
                ),

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
      builder: (dialogContext) => _GraphicFormDialog(
        title: 'Add New Graphic',
        onSubmit: (name, width, height, dataLength) {
          final data = List.generate(dataLength, (index) => index % 256);
          final graphic = Graphics(
            name: name,
            data: data,
            width: width,
            height: height,
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
      builder: (dialogContext) => _GraphicFormDialog(
        title: 'Edit Graphic',
        initialName: graphic.name,
        initialWidth: graphic.width,
        initialHeight: graphic.height,
        initialDataLength: graphic.data.length,
        initialTileOrigin: 0,
        onSubmit: (name, width, height, dataLength) {
          // Create updated graphic with new dimensions but preserve some original data
          final data = List.generate(
            dataLength,
            (i) => i < graphic.data.length ? graphic.data[i] : 0,
          );
          final updatedGraphic = Graphics(
            name: name,
            data: data,
            width: width,
            height: height,
            tileOrigin: 0, //WIP
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

  bool _setMetaTile(Graphics Graphics, BuildContext context) {
    bool hasLoaded = true;
    try {
      context.read<AppStateCubit>().setTileName(Graphics.name);
      var data = GBDKTileConverter().combine(Graphics.data);
      data = GBDKTileConverter().reorderFromSourceToCanvas(
        data,
        context.read<MetaTileCubit>().state.width,
        context.read<MetaTileCubit>().state.height,
      );
      context.read<MetaTileCubit>().setData(data);
    } catch (e) {
      if (kDebugMode) {
        print("ERROR $e");
      }
      hasLoaded = false;
    }

    if (hasLoaded) context.read<AppStateCubit>().setSelectedTileIndex(0);

    return hasLoaded;
  }

  void _showTilePreviewDialog(BuildContext context, graphic) {
    final controller = TextEditingController();
    var data = GBDKTileConverter().combine(graphic.data);
    data = GBDKTileConverter().reorderFromSourceToCanvas(
      data,
      context.read<MetaTileCubit>().state.width,
      context.read<MetaTileCubit>().state.height,
    );
    var preview = MetaTile(height: 8, width: 8, data: data);

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
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Tile Origin"),
                  keyboardType: TextInputType.number,
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
                      preview.data.length ~/ (preview.height * preview.width),
                      (index) => SizedBox(
                        width: 40,
                        height: 40,
                        child: MetaTileDisplay(
                          showGrid: false,
                          tileData: preview.getTileAtIndex(index),
                        ),
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
              print("Load '${graphic.name}' as Tile with origin $origin");
              _setMetaTile(graphic, context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _loadAsBackground(Graphics graphics, BuildContext context) {
    print("Load '${graphic.name}' as Background");
    Background background = GBDKBackgroundConverter().fromGraphics(graphics);
    context.read<BackgroundCubit>().setData(background.data);
  }

  void _showBackgroundPreviewDialog(BuildContext context, graphic) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.8,
            height: MediaQuery.of(ctx).size.height * 0.8,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Preview",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: BackgroundGrid(
                    background: context.read<BackgroundCubit>().state,
                    tileOrigin: context
                        .read<BackgroundCubit>()
                        .state
                        .tileOrigin,
                    metaTile: context.read<MetaTileCubit>().state,
                    showGrid: true,
                    cellSize: 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _loadAsBackground(graphic, context);
                    },
                    child: const Text("Load"),
                  ),
                ),
              ],
            ),
          ),
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
              icon: const Icon(Icons.memory),
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
                    title: Text("Load as Tile"),
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
              tooltip: 'Edit Graphic',
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

class _GraphicFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final int? initialWidth;
  final int? initialHeight;
  final int? initialDataLength;
  final int? initialTileOrigin;
  final Function(String name, int width, int height, int dataLength) onSubmit;

  const _GraphicFormDialog({
    Key? key,
    required this.title,
    required this.onSubmit,
    this.initialName,
    this.initialWidth,
    this.initialHeight,
    this.initialDataLength,
    this.initialTileOrigin,
  }) : super(key: key);

  @override
  State<_GraphicFormDialog> createState() => _GraphicFormDialogState();
}

class _GraphicFormDialogState extends State<_GraphicFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _dataLengthController;
  late TextEditingController _tileOriginController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _widthController = TextEditingController(
      text: widget.initialWidth?.toString() ?? '8',
    );
    _heightController = TextEditingController(
      text: widget.initialHeight?.toString() ?? '8',
    );
    _dataLengthController = TextEditingController(text: '0');
    _tileOriginController = TextEditingController(text: '0');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter width';
                  final width = int.tryParse(value);
                  if (width == null || width < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter height';
                  final height = int.tryParse(value);
                  if (height == null || height < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),
              /*const SizedBox(height: 16),
              TextFormField(
                controller: _tileOriginController,
                decoration: const InputDecoration(labelText: 'Tile Origin'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter tile origin';
                  final origin = int.tryParse(value);
                  if (origin == null || origin < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),*/
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text.trim();
              final width = int.parse(_widthController.text);
              final height = int.parse(_heightController.text);
              final tileOrigin = int.parse(_tileOriginController.text);

              Navigator.of(context).pop();
              widget.onSubmit(name, width, height, tileOrigin);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _tileOriginController.dispose();
    super.dispose();
  }
}
