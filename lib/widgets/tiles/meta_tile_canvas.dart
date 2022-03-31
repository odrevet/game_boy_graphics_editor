import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';
import '../../tile.dart';

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
              var localPosition = details.localPosition;
              final pixelSize = constraints.maxWidth / widget.metaTile.width;
              final rowIndex = (localPosition.dx / pixelSize).floor();
              final colIndex = (localPosition.dy / pixelSize).floor();

              int tileIndex = (rowIndex ~/ Tile.size) +
                  (colIndex ~/ Tile.size) * widget.metaTile.nbTilePerRow();
              int metaTileIndex = widget.pattern[tileIndex] +
                  widget.metaTileIndex * widget.metaTile.nbTilePerMetaTile();
              int pixelIndex =
                  ((colIndex % Tile.size) * Tile.size) + (rowIndex % Tile.size);
              widget.onTap!(metaTileIndex, pixelIndex);
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
}
