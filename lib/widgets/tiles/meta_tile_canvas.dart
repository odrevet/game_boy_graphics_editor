import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';

class MetaTileCanvas extends StatefulWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final bool floodMode;
  final int metaTileIndex;
  final List<Color> colorSet;

  late final List<int> pattern;

  MetaTileCanvas(
      {required this.metaTile,
      required this.showGrid,
      required this.floodMode,
      required this.metaTileIndex,
      required this.colorSet,
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
            if (isHover && widget.floodMode == false) {
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
            colorSet: widget.colorSet,
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
    int indexTile = index[0];
    int indexPixel = index[1];

    if (widget.floodMode) {
      int targetColor = widget.metaTile.tileList[indexTile].data[indexPixel];
      flood(rowIndex, colIndex, targetColor);
    } else {
      widget.onTap!(indexTile, indexPixel);
    }
  }

  flood(int rowIndex, int colIndex, int targetColor) {
    var index =
        widget.metaTile.getTileIndex(rowIndex, colIndex, widget.metaTileIndex);

    int indexTile = index[0];
    int indexPixel = index[1];

    if (widget.metaTile.tileList[indexTile].data[indexPixel] == targetColor) {
      widget.onTap!(indexTile, indexPixel);
      if (inbound(rowIndex, colIndex - 1)) {
        flood(rowIndex, colIndex - 1, targetColor);
      }
      if (inbound(rowIndex, colIndex + 1)) {
        flood(rowIndex, colIndex + 1, targetColor);
      }
      if (inbound(rowIndex - 1, colIndex)) {
        flood(rowIndex - 1, colIndex, targetColor);
      }
      if (inbound(rowIndex + 1, colIndex)) {
        flood(rowIndex + 1, colIndex, targetColor);
      }
    }
  }

  inbound(int rowIndex, int colIndex) =>
      rowIndex >= 0 &&
      rowIndex < widget.metaTile.height &&
      colIndex >= 0 &&
      colIndex < widget.metaTile.width;
}
