import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/dot_matrix.dart';

import '../colors.dart';

class TileWidget extends StatefulWidget {
  final List<int> intensity;
  final Function? onTap;

  const TileWidget({Key? key, required this.intensity, this.onTap})
      : super(key: key);

  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  @override
  Widget build(BuildContext context) {
    return DotMatrix(
      pixels: widget.intensity.map((e) => colors[e]).toList(),
      showGrid: true,
      onTap: (index) => print(index),
    );
  }
}
