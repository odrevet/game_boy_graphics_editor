import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import '../tiles.dart';

class MapWidget extends StatefulWidget {
  final Background background;
  final Tiles tiles;
  final Function? onTap;

  const MapWidget(
      {Key? key,
      required this.background,
      required this.tiles,
      required this.onTap})
      : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
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
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () => widget.onTap!(index),
        child: TileWidget(
            intensity: widget.tiles.data.sublist(
                (widget.tiles.size * widget.tiles.size) *
                    widget.background.data[index],
                (widget.tiles.size * widget.tiles.size) *
                    (widget.background.data[index] + 1))),
      );
    }
    {
      return TileWidget(
          intensity: widget.tiles.data.sublist(
              (widget.tiles.size * widget.tiles.size) *
                  widget.background.data[index],
              (widget.tiles.size * widget.tiles.size) *
                  (widget.background.data[index] + 1)));
    }
  }
}
