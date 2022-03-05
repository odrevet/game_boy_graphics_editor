import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbdk_graphic_editor/widgets/background_widget.dart';
import 'package:gbdk_graphic_editor/widgets/graphics_data_display.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../background.dart';
import '../tiles.dart';

class BackgroundEditor extends StatefulWidget {
  final Tiles tiles;
  final Background background;
  final int selectedTileIndex;
  final Function? onTapTileListView;
  final bool showGrid;

  const BackgroundEditor(
      {Key? key,
      required this.tiles,
      required this.background,
      required this.selectedTileIndex,
      this.onTapTileListView,
      this.showGrid = false})
      : super(key: key);

  @override
  State<BackgroundEditor> createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
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
        child: BackgroundWidget(
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
              initialValue: widget.background.name,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (text) => setState(() {
                widget.background.name = text;
              }),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              initialValue: widget.background.height.toString(),
              decoration: const InputDecoration(labelText: 'Height'),
              onChanged: (text) => setState(() {
                widget.background.width = int.tryParse(text) ?? 18;
                if (widget.background.width > 32) {
                  widget.background.width = 32;
                }
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            TextFormField(
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              initialValue: widget.background.width.toString(),
              decoration: const InputDecoration(labelText: 'Width'),
              onChanged: (text) => setState(() {
                widget.background.height = int.tryParse(text) ?? 20;
                if (widget.background.height > 32) {
                  widget.background.height = 32;
                }

                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
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
