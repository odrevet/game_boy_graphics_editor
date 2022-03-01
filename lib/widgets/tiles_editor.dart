import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import '../tiles.dart';
import 'background_widget.dart';

class TilesEditor extends StatelessWidget {
  final Background preview;
  final Tiles tiles;
  final Function setTilesIndex;
  final Function setPixel;
  final bool showGrid;

  const TilesEditor(
      {Key? key,
      required this.preview,
      required this.tiles,
      required this.setTilesIndex,
      required this.showGrid,
      required this.setPixel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      TileListView(onTap: (index) => setTilesIndex(index), tiles: tiles),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child:
              TileWidget(onTap: setPixel, intensity: tiles.getData(tiles.index), showGrid: showGrid,),
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BackgroundWidget(
                background: preview,
                tiles: tiles,
                onTap: null,
              ),
            ),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(tiles.toSource()))),
          ],
        ),
      )
    ]);
  }
}
