import 'package:flutter/material.dart';

import 'pixel.dart';

class TileWidget extends StatefulWidget {
  final List intensity;
  final Function? onTap;

  const TileWidget({Key? key, required this.intensity, this.onTap})
      : super(key: key);

  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  int tileSize = 8;

  Widget _buildEditor(BuildContext context, int index) {
    if (widget.onTap != null) {
      return GridTile(
        child: GestureDetector(
          onTap: () => widget.onTap!(index),
          child: PixelWidget(intensity: widget.intensity[index]),
        ),
      );
    } else {
      return PixelWidget(intensity: widget.intensity[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: _buildEditor,
        itemCount: tileSize * tileSize,
      ),
    );
  }
}
