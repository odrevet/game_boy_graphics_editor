import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';

class TileListView extends StatefulWidget {
  final MetaTile tiles;
  final int selectedTile;
  final Function onTap;
  final Function? onHover;

  const TileListView({
    Key? key,
    required this.tiles,
    required this.selectedTile,
    required this.onTap,
    this.onHover,
  }) : super(key: key);

  @override
  _TileListViewState createState() => _TileListViewState();
}

class _TileListViewState extends State<TileListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 180,
        child: ListView.builder(
          itemCount: widget.tiles.count(),
          itemBuilder: (context, index) {
            return MouseRegion(
              onHover: (_) =>
                  widget.onHover != null ? widget.onHover!(index) : null,
              child: ListTile(
                onTap: () => widget.onTap(index),
                leading: Text(
                  "$index",
                  style: widget.selectedTile == index
                      ? const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)
                      : null,
                ),
                title: MetaTileDisplay(
                    tiles: widget.tiles,
                    showGrid: false,
                    selectedTileIndex: index),
              ),
            );
          },
        ));
  }
}
