import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';

import '../colors.dart';
import '../tiles.dart';
import 'dot_matrix.dart';

class BackgroundWidget extends StatefulWidget {
  final Background background;
  final Tiles tiles;
  final Function? onTap;
  final bool showGrid;

  const BackgroundWidget(
      {Key? key,
      required this.background,
      required this.tiles,
      required this.onTap,
      this.showGrid = false})
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
    Widget tileWidget;

    if (widget.background.data[index] >= widget.tiles.count) {
      tileWidget = Container(
        alignment: Alignment.center,
        child: const Text(
          'Error',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      );
    } else {
      tileWidget = DotMatrix(
          pixels: widget.tiles.data
              .sublist(
                  (widget.tiles.size * widget.tiles.size) *
                      widget.background.data[index],
                  (widget.tiles.size * widget.tiles.size) *
                      (widget.background.data[index] + 1))
              .map((e) => colors[e])
              .toList());
    }

    if (widget.showGrid) {
      tileWidget = Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
        child: tileWidget,
      );
    }

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
