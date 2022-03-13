import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';
import 'package:gbdk_graphic_editor/widgets/tiles_grid.dart';

import '../colors.dart';
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
        width: 200,
        child: ListView.builder(
          itemCount: widget.tiles.count(),
          itemBuilder: (context, index) {
            bool isSelected = widget.selectedTile == index;
            Color color = isSelected == true ? Colors.blue : Colors.grey;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: color,
                        indent: 20.0,
                        endIndent: 10.0,
                        thickness: 1,
                      ),
                    ),
                    Text(
                      "$index",
                      style: TextStyle(color: color),
                    ),
                    Expanded(
                      child: Divider(
                        color: color,
                        indent: 10.0,
                        endIndent: 20.0,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => widget.onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TilesGrid(
                        tiles: widget.tiles,
                        showGrid: false,
                        selectedTileIndex: index,
                        setPixel: () => print("click")),
                  ),
                )
              ],
            );
          },
        ));
  }
}
