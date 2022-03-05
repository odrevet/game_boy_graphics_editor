import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/background_widget.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../background.dart';
import '../tiles.dart';

class BackgroundEditor extends StatefulWidget {
  final Tiles tiles;
  final Background background;
  final int selectedTileIndex;
  final Function? onTapTileListView;

  const BackgroundEditor({
    Key? key,
    required this.tiles,
    required this.background,
    required this.selectedTileIndex,
    this.onTapTileListView,
  }) : super(key: key);

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
              decoration: const InputDecoration(
                  labelText: 'Name'
              ),
              onChanged: (text) => setState(() {
                widget.background.name = text;
              }),
            ),
            TextFormField(
              initialValue: widget.background.height.toString(),
              decoration: const InputDecoration(
                  labelText: 'Height'
              ),
              onChanged: (text) => setState(() {
                widget.background.height = int.parse(text);
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            TextFormField(
              initialValue: widget.background.width.toString(),
              decoration: const InputDecoration(
                  labelText: 'Width'
              ),
              onChanged: (text) => setState(() {
                widget.background.width = int.parse(text);
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            Column(
              children: [
                Text("${widget.background.name}.h"),
                Align(alignment: Alignment.topLeft, child: SelectableText(widget.background.toHeader())),
                const Divider(),
                Text("${widget.background.name}.c"),
                Align(alignment: Alignment.topLeft, child: SelectableText(widget.background.toSource())),
              ],
            ),
          ],
        ),
      )
    ]);
  }
}
