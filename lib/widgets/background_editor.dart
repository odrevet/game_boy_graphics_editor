import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/background_grid.dart';
import 'package:gbdk_graphic_editor/widgets/source_display.dart';
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
  int hoverTileIndex = 0;

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
        child: ContextMenuRegion(
          contextMenu: GenericContextMenu(
            buttonConfigs: [
              ContextMenuButtonConfig("Insert column before",
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() {
                        widget.background.insertCol(
                            hoverTileIndex % widget.background.width,
                            widget.selectedTileIndex);
                      }))
            ],
          ),
          child: BackgroundGrid(
            showGrid: widget.showGrid,
            background: widget.background,
            tiles: widget.tiles,
            onTap: (index) => setState(() {
              widget.background.data[index] = widget.selectedTileIndex;
            }),
            onHover: (index) => setState(() {
              hoverTileIndex = index;
            }),
          ),
        ),
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
            Row(
              children: [
                Text("Width ${widget.background.width}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Column',
                    onPressed: () => setState(() {
                          widget.background.insertCol(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Column',
                    onPressed: () => widget.background.width > 1
                        ? setState(() {
                            widget.background.deleteCol(0);
                          })
                        : null),
              ],
            ),
            Row(
              children: [
                Text("Height ${widget.background.height}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Row',
                    onPressed: () => setState(() {
                          widget.background.insertRow(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Row',
                    onPressed: () => widget.background.height > 1
                        ? setState(() {
                            widget.background.deleteRow(0);
                          })
                        : null),
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: SourceDisplay(graphics: widget.background),
            )),
          ],
        ),
      )
    ]);
  }
}
