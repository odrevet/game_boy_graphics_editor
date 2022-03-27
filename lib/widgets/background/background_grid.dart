import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/background.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';

class BackgroundGrid extends StatefulWidget {
  final Background background;
  final MetaTile tiles;
  final Function? onTap;
  final Function? onHover;
  final bool showGrid;

  const BackgroundGrid(
      {Key? key,
      required this.background,
      required this.tiles,
      this.onTap,
      this.onHover,
      this.showGrid = false})
      : super(key: key);

  @override
  _BackgroundGridState createState() => _BackgroundGridState();
}

class _BackgroundGridState extends State<BackgroundGrid> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: widget.tiles.width / widget.tiles.height,
          crossAxisCount: widget.background.width,
        ),
        itemBuilder: _build,
        itemCount: widget.background.width * widget.background.height,
      ),
    );
  }

  Widget _build(BuildContext context, int index) {
    Widget tileWidget;

    if (widget.background.data[index] >= widget.tiles.tileList.length) {
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
      tileWidget = MetaTileDisplay(
          metaTile: widget.tiles,
          showGrid: false,
          metaTileIndex: widget.background.data[index]);
    }

    if (widget.showGrid) {
      tileWidget = Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
        child: tileWidget,
      );
    }

    if (widget.onTap != null) {
      return MouseRegion(
        onHover: (_) => widget.onHover != null ? widget.onHover!(index) : null,
        cursor: SystemMouseCursors.precise,
        child: GestureDetector(
          onTap: () => widget.onTap!(index),
          child: tileWidget,
        ),
      );
    }
    {
      return tileWidget;
    }
  }
}
