import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles_grid.dart';

import '../tiles.dart';

class TileListView extends StatefulWidget {
  final Tiles tiles;
  final int selectedTile;
  final Function onTap;

  const TileListView(
      {Key? key,
      required this.tiles,
      required this.selectedTile,
      required this.onTap})
      : super(key: key);

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
            return Card(
              child: ListTile(
                onTap: () => widget.onTap(index),
                leading: Text(
                  "$index",
                  style: TextStyle(
                      color: widget.selectedTile == index
                          ? Colors.blue
                          : Colors.grey),
                ),
                title: TilesGrid(
                    tiles: widget.tiles,
                    showGrid: false,
                    selectedTileIndex: index),
              ),
            );
          },
        ));
  }
}
