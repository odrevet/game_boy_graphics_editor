import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';

import '../colors.dart';
import '../tiles.dart';
import 'dot_matrix.dart';

class BackgroundWidget extends StatefulWidget {
  final Background background;
  final Tiles tiles;
  final Function? onTap;

  const BackgroundWidget(
      {Key? key,
      required this.background,
      required this.tiles,
      required this.onTap})
      : super(key: key);

  @override
  _BackgroundWidgetState createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.background.width,
        ),
        itemBuilder: _build,
        itemCount: widget.background.width * widget.background.height,
      ),
    );
  }

  Widget _build(BuildContext context, int index) {
    Widget tileWidget = DotMatrix(
        pixels: widget.tiles.data
            .sublist(
                (widget.tiles.size * widget.tiles.size) *
                    widget.background.data[index],
                (widget.tiles.size * widget.tiles.size) *
                    (widget.background.data[index] + 1))
            .map((e) => colors[e])
            .toList());

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () => widget.onTap!(index),
        child: tileWidget,
      );
    }
    {
      return tileWidget;
    }
  }
}
