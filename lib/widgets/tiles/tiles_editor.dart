import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/tile_list_view.dart';

import '../../meta_tile.dart';
import '../background/background_grid.dart';
import '../source_display.dart';

class TilesEditor extends StatefulWidget {
  final Background preview;
  final MetaTile tiles;
  final Function setIndex;
  final Function setPixel;
  final bool showGrid;
  final int selectedIndex;
  final Function onRemove;
  final Function onInsert;
  final Function copy;
  final Function past;

  const TilesEditor({
    Key? key,
    required this.preview,
    required this.tiles,
    required this.setIndex,
    required this.showGrid,
    required this.setPixel,
    required this.selectedIndex,
    required this.onRemove,
    required this.onInsert,
    required this.copy,
    required this.past,
  }) : super(key: key);

  @override
  State<TilesEditor> createState() => _TilesEditorState();
}

class _TilesEditorState extends State<TilesEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ContextMenuRegion(
        child: TileListView(
            onHover: (index) => setState(() {
                  hoverTileIndex = index;
                }),
            onTap: (index) => widget.setIndex(index),
            tiles: widget.tiles,
            selectedTile: widget.selectedIndex),
        contextMenu: GenericContextMenu(
          buttonConfigs: [
            ContextMenuButtonConfig(
              "Insert before",
              icon: const Icon(Icons.add),
              onPressed: () => widget.onInsert(hoverTileIndex),
            ),
            ContextMenuButtonConfig(
              "Delete",
              icon: const Icon(Icons.remove),
              onPressed: () => widget.onRemove(hoverTileIndex),
            ),
            ContextMenuButtonConfig(
              "Copy",
              icon: const Icon(Icons.copy),
              onPressed: () => widget.copy(hoverTileIndex),
            ),
            ContextMenuButtonConfig(
              "Paste",
              icon: const Icon(Icons.paste),
              onPressed: () => widget.past(hoverTileIndex),
            )
          ],
        ),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.topCenter,
          child: AspectRatio(
            aspectRatio: widget.tiles.width / widget.tiles.height,
            child: MetaTileDisplay(
                metaTile: widget.tiles,
                showGrid: widget.showGrid,
                selectedTileIndex: widget.selectedIndex,
                onTap: widget.setPixel),
          ),
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: BackgroundGrid(
                    background: widget.preview, tiles: widget.tiles),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SourceDisplay(
                  graphics: widget.tiles,
                ),
              ),
            )
          ],
        ),
      )
    ]);
  }
}
