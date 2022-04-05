import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_canvas.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../meta_tile.dart';
import '../background/background_grid.dart';
import '../source_display.dart';

class TilesEditor extends StatefulWidget {
  final Background preview;
  final MetaTile metaTile;
  final Function setIndex;
  final Function setPixel;
  final bool showGrid;
  final bool floodMode;
  final int selectedIndex;
  final Function onRemove;
  final Function onInsert;
  final Function copy;
  final Function past;
  final List<Color> colorSet;

  const TilesEditor({
    Key? key,
    required this.preview,
    required this.metaTile,
    required this.setIndex,
    required this.showGrid,
    required this.floodMode,
    required this.setPixel,
    required this.selectedIndex,
    required this.onRemove,
    required this.onInsert,
    required this.copy,
    required this.past,
    required this.colorSet,
  }) : super(key: key);

  @override
  State<TilesEditor> createState() => _TilesEditorState();
}

class _TilesEditorState extends State<TilesEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ContextMenuArea(
        builder: (BuildContext context) => [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Insert before"),
            onTap: () {
              widget.onInsert(hoverTileIndex);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove),
            title: const Text("Delete"),
            onTap: () {
              widget.onRemove(hoverTileIndex);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
            onTap: () {
              widget.copy(hoverTileIndex);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.paste),
            title: const Text("Paste"),
            onTap: () {
              widget.past(hoverTileIndex);
              Navigator.pop(context);
            },
          ),
        ],
        child: MetaTileListView(
            onHover: (index) => setState(() {
                  hoverTileIndex = index;
                }),
            onTap: (index) => widget.setIndex(index),
            metaTile: widget.metaTile,
            selectedTile: widget.selectedIndex,
            colorSet: widget.colorSet),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.topCenter,
          child: AspectRatio(
            aspectRatio: widget.metaTile.width / widget.metaTile.height,
            child: MetaTileCanvas(
                metaTile: widget.metaTile,
                showGrid: widget.showGrid,
                floodMode: widget.floodMode,
                metaTileIndex: widget.selectedIndex,
                onTap: widget.setPixel,
                colorSet: widget.colorSet),
          ),
        ),
      ),
      Expanded(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              initialValue: widget.metaTile.name,
              onChanged: (text) => setState(() {
                widget.metaTile.name = text;
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: BackgroundGrid(
                  background: widget.preview,
                  metaTile: widget.metaTile,
                  colorSet: widget.colorSet,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SourceDisplay(
                  graphics: widget.metaTile,
                ),
              ),
            )
          ],
        ),
      )
    ]);
  }
}
