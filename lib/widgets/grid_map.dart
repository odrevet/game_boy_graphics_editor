import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

class GridMap extends StatefulWidget {
  final List<int> mapData;
  final List<int> spriteData;
  final int spriteSize;

  const GridMap(
      {Key? key,
      required this.mapData,
      required this.spriteData,
      required this.spriteSize})
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
    return PixelGridWidget(
        intensity: widget.spriteData.sublist(
            (widget.spriteSize * widget.spriteSize) * widget.mapData[index],
            (widget.spriteSize * widget.spriteSize) *
                (widget.mapData[index] + 1)));
  }
}
