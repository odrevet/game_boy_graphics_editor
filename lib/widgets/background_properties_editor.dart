import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:gbdk_graphic_editor/widgets/background_grid.dart';
import 'package:gbdk_graphic_editor/widgets/graphics_data_display.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../background.dart';
import '../tiles.dart';

class BackgroundPropertiesEditor extends StatefulWidget {
  final Tiles tiles;
  final Background background;
  final int selectedTileIndex;
  final Function? onTapTileListView;
  final bool showGrid;

  const BackgroundPropertiesEditor(
      {Key? key,
      required this.tiles,
      required this.background,
      required this.selectedTileIndex,
      this.onTapTileListView,
      this.showGrid = false})
      : super(key: key);

  @override
  State<BackgroundPropertiesEditor> createState() => _BackgroundPropertiesEditorState();
}

class _BackgroundPropertiesEditorState extends State<BackgroundPropertiesEditor> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TileListView(
          onTap: (index) => widget.onTapTileListView != null
              ? widget.onTapTileListView!(index)
              : null,
          tiles: widget.tiles,
          selectedTile: widget.selectedTileIndex),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: BackgroundGrid(
            showGrid: widget.showGrid,
            background: widget.background,
            tiles: widget.tiles,
            onTap: (index) => setState(() {
                  widget.background.data[index] = widget.selectedTileIndex;
                })),
      ),
      Flexible(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              initialValue: widget.background.name,
              onChanged: (text) => setState(() {
                widget.background.name = text;
              }),
            ),
            SpinBox(
              decoration: const InputDecoration(labelText: 'Height'),
              min: 1,
              max: 32,
              value: widget.background.height.toDouble(),
              onChanged: (value) => setState(() {
                widget.background.height = value.toInt();
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            SpinBox(
                decoration: const InputDecoration(labelText: 'Width'),
                min: 1,
                max: 32,
                value: widget.background.width.toDouble(),
                onChanged: (value) => setState(() {
                      widget.background.width = value.toInt();
                      widget.background.data = List.filled(
                          widget.background.height * widget.background.width,
                          0);
                    })),
            Expanded(
                child: SingleChildScrollView(
              child: GraphicsDataDisplay(graphics: widget.background),
            )),
          ],
        ),
      )
    ]);
  }
}
