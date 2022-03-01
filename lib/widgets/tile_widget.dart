import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';

import '../colors.dart';

class TileWidget extends StatefulWidget {
  final List<int> intensity;
  final Function? onTap;
  final bool showGrid;

  const TileWidget({Key? key, required this.intensity, this.onTap, this.showGrid = false})
      : super(key: key);

  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  @override
  Widget build(BuildContext context) {
    return DotMatrix(
      pixels: widget.intensity.map((e) => colors[e]).toList(),
      showGrid: widget.showGrid,
      onTap: (index) => print(index),
    );
  }
}
