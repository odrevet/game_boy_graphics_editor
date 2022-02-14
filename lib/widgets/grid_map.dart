import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

class GridMap extends StatefulWidget {
  final List<int> intensity;
  final int spriteSize;
  final int spriteIndex;

  const GridMap(
      {Key? key,
      required this.intensity,
      required this.spriteSize,
      required this.spriteIndex})
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
        itemBuilder: _buildEditor,
        itemCount: 16,
      ),
    );
  }

  Widget _buildEditor(BuildContext context, int index) {
    return PixelGridWidget(
        intensity: widget.intensity.sublist(
            (widget.spriteSize * widget.spriteSize) * widget.spriteIndex,
            (widget.spriteSize * widget.spriteSize) *
                (widget.spriteIndex + 1)));
  }
}
