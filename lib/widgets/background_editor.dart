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
            Text('Height ${widget.background.height}'),
            TextField(
              onChanged: (text) => setState(() {
                widget.background.height = int.parse(text);
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            Text('Width ${widget.background.width}'),
            TextField(
              onChanged: (text) => setState(() {
                widget.background.width = int.parse(text);
                widget.background.data = List.filled(
                    widget.background.height * widget.background.width, 0);
              }),
            ),
            Flexible(
              child: SelectableText(widget.background.toSource()),
            ),
          ],
        ),
      )
    ]);
  }
}
