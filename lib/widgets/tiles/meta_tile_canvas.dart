import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';

class MetaTileCanvas extends StatefulWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final int metaTileIndex;

  late final List<int> pattern;

  MetaTileCanvas(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    pattern = metaTile.getPattern();
  }

  @override
  State<MetaTileCanvas> createState() => _MetaTileCanvasState();
}

class _MetaTileCanvasState extends State<MetaTileCanvas> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          MouseRegion(
        cursor: SystemMouseCursors.precise,
        onEnter: (PointerEvent details) => setState(() => isHover = true),
        onExit: (PointerEvent details) => setState(() {
          isHover = false;
        }),
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (isHover) {
              draw(details, constraints);
            }
          },
          onTapDown: (TapDownDetails details) {
            if (isHover) {
              draw(details, constraints);
            }
          },
          child: MetaTileDisplay(
            metaTileIndex: widget.metaTileIndex,
            metaTile: widget.metaTile,
            showGrid: widget.showGrid,
          ),
        ),
      ),
    );
  }

  draw(dynamic details, BoxConstraints constraints) {
    var localPosition = details.localPosition;
    final pixelSize = constraints.maxWidth / widget.metaTile.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();

    var index =
        widget.metaTile.getTileIndex(rowIndex, colIndex, widget.metaTileIndex);

    widget.onTap!(index[0], index[1]);
  }
}
