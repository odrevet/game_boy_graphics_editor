import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_canvas.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../meta_tile.dart';
import '../../meta_tile_cubit.dart';
import '../background/background_grid.dart';
import '../source_display.dart';

class TilesEditor extends StatefulWidget {
  final Background preview;
  final MetaTile metaTile;
  final Function setIndex;
  final bool showGrid;
  final bool floodMode;
  final int selectedIndex;
  final List<Color> colorSet;
  final int selectedIntensity;
  final List<int> tileBuffer;

  const TilesEditor({
    Key? key,
    required this.preview,
    required this.metaTile,
    required this.setIndex,
    required this.showGrid,
    required this.floodMode,
    required this.selectedIndex,
    required this.colorSet,
    required this.selectedIntensity,
    required this.tileBuffer,
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
        builder: (BuildContext contextMenuAreaContext) => [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("Insert before"),
            onTap: () {
              context.read<MetaTileCubit>().insert(hoverTileIndex);
              Navigator.pop(contextMenuAreaContext);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove),
            title: const Text("Delete"),
            onTap: () {
              context.read<MetaTileCubit>().remove(hoverTileIndex);
              Navigator.pop(contextMenuAreaContext);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
            onTap: () {
              context
                  .read<MetaTileCubit>()
                  .copy(hoverTileIndex, widget.tileBuffer);
              Navigator.pop(contextMenuAreaContext);
            },
          ),
          ListTile(
            leading: const Icon(Icons.paste),
            title: const Text("Paste"),
            onTap: () {
              context
                  .read<MetaTileCubit>()
                  .paste(hoverTileIndex, widget.tileBuffer);
              Navigator.pop(contextMenuAreaContext);
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
                intensity: widget.selectedIntensity,
                metaTile: widget.metaTile,
                showGrid: widget.showGrid,
                floodMode: widget.floodMode,
                metaTileIndex: widget.selectedIndex,
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
