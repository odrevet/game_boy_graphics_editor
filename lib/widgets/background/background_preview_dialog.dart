import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/converter_utils.dart';

import '../../cubits/meta_tile_cubit.dart';
import '../../models/graphics/background.dart';
import '../../models/sourceConverters/gbdk_background_converter.dart';
import 'background_grid.dart';

class BackgroundPreviewDialog extends StatefulWidget {
  final dynamic graphic;
  final VoidCallback onLoad;
  final String? title;
  final double? dialogWidth;
  final double? dialogHeight;
  final double cellSize;
  final bool showGrid;

  const BackgroundPreviewDialog({
    Key? key,
    required this.graphic,
    required this.onLoad,
    this.title,
    this.dialogWidth,
    this.dialogHeight,
    this.cellSize = 32,
    this.showGrid = true,
  }) : super(key: key);

  @override
  State<BackgroundPreviewDialog> createState() =>
      _BackgroundPreviewDialogState();
}

class _BackgroundPreviewDialogState extends State<BackgroundPreviewDialog> {
  bool transpose = true;

  @override
  Widget build(BuildContext context) {
    final Background preview = GBDKBackgroundConverter().fromGraphics(
      widget.graphic,
    );

    if (transpose) {
      var data = transposeList(
        preview.data,
        widget.graphic.height ~/ 8,
        widget.graphic.width ~/ 8,
      );
      preview.data = data;
    }

    final screenSize = MediaQuery
        .of(context)
        .size;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.title ?? "Load ${widget.graphic.name} as Background",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: widget.dialogWidth ?? screenSize.width * 0.8,
        height: widget.dialogHeight ?? screenSize.height * 0.6,
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: transpose,
                  onChanged: (value) {
                    setState(() {
                      transpose = value ?? false;
                    });
                  },
                ),
                const Text("Transpose"),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BackgroundGrid(
                background: preview,
                tileOrigin: 0,
                metaTile: context
                    .read<MetaTileCubit>()
                    .state,
                showGrid: widget.showGrid,
                cellSize: widget.cellSize,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onLoad();
          },
          child: const Text("Load"),
        ),
      ],
    );
  }
}
