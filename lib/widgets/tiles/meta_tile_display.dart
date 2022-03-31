import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/dot_matrix.dart';

import '../../colors.dart';
import '../../meta_tile.dart';
import '../../tile.dart';

class MetaTileDisplay extends StatefulWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final int metaTileIndex;

  late final List<int> pattern;

  MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    pattern = metaTile.getPattern();
  }

  @override
  State<MetaTileDisplay> createState() => _MetaTileDisplayState();
}

class _MetaTileDisplayState extends State<MetaTileDisplay> {
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
              var clickOffset = details.localPosition;
              final pixelSize = constraints.maxWidth / widget.metaTile.width;
              final tapedRow = (clickOffset.dx / pixelSize).floor();
              final tapedColumn = (clickOffset.dy / pixelSize).floor();

              int tileIndex = (tapedRow ~/ Tile.size) +
                  (tapedColumn ~/ Tile.size) * widget.metaTile.nbTilePerRow();
              int metaTileIndex = widget.pattern[tileIndex] +
                  widget.metaTileIndex * widget.metaTile.nbTilePerMetaTile();
              int pixelIndex = ((tapedColumn % Tile.size) * Tile.size) +
                  (tapedRow % Tile.size);
              widget.onTap!(metaTileIndex, pixelIndex);
            }
          },
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: widget.metaTile.nbTilePerRow(),
            children: <Widget>[
              for (int i = 0; i < widget.metaTile.nbTilePerMetaTile(); i++)
                DotMatrix(
                    pixels: widget
                        .metaTile
                        .tileList[widget.metaTileIndex *
                                widget.metaTile.nbTilePerMetaTile() +
                            widget.pattern[i]]
                        .data
                        .map((e) => colors[e])
                        .toList(),
                    showGrid: widget.showGrid)
            ],
          ),
        ),
      ),
    );
  }
}
