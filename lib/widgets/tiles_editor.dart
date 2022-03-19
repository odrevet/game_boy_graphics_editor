import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/meta_tile.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';

import '../tiles.dart';
import 'background_grid.dart';
import 'source_display.dart';

class TilesEditor extends StatefulWidget {
  final Background preview;
  final Tiles tiles;
  final Function setTilesIndex;
  final Function setPixel;
  final bool showGrid;
  final int selectedTileIndex;
  final Function onRemoveTile;

  const TilesEditor(
      {Key? key,
      required this.preview,
      required this.tiles,
      required this.setTilesIndex,
      required this.showGrid,
      required this.setPixel,
      required this.selectedTileIndex,
      required this.onRemoveTile})
      : super(key: key);

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
            onTap: (index) => widget.setTilesIndex(index),
            tiles: widget.tiles,
            selectedTile: widget.selectedTileIndex),
        contextMenu: GenericContextMenu(
          buttonConfigs: [
            ContextMenuButtonConfig(
              "Delete",
              icon: const Icon(Icons.remove),
              onPressed: () => widget.onRemoveTile(hoverTileIndex),
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
            child: MetaTile(
                tiles: widget.tiles,
                showGrid: widget.showGrid,
                selectedTileIndex: widget.selectedTileIndex,
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
