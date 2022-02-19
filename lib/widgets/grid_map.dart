import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

class GridMap extends StatefulWidget {
  final List<int> mapData;
  final List<int> tileData;
  final int tileSize;
  final Function? onTap;

  const GridMap(
      {Key? key,
      required this.mapData,
      required this.tileData,
      required this.tileSize,
      required this.onTap})
      : super(key: key);

  @override
  _GridMapState createState() => _GridMapState();
}

class _GridMapState extends State<GridMap> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: _build,
        itemCount: 16,
      ),
    );
  }

  Widget _build(BuildContext context, int index) {
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () => widget.onTap!(index),
        child: PixelGridWidget(
            intensity: widget.tileData.sublist(
                (widget.tileSize * widget.tileSize) * widget.mapData[index],
                (widget.tileSize * widget.tileSize) *
                    (widget.mapData[index] + 1))),
      );
    }
    {
      return PixelGridWidget(
          intensity: widget.tileData.sublist(
              (widget.tileSize * widget.tileSize) * widget.mapData[index],
              (widget.tileSize * widget.tileSize) *
                  (widget.mapData[index] + 1)));
    }
  }
}
