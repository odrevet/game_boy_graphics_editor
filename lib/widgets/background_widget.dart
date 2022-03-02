import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import '../tiles.dart';

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
    Widget tileWidget = TileWidget(
        intensity: widget.tiles.data.sublist(
            (widget.tiles.size * widget.tiles.size) *
                widget.background.data[index],
            (widget.tiles.size * widget.tiles.size) *
                (widget.background.data[index] + 1)));

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
