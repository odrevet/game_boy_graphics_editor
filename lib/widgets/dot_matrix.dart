import 'package:flutter/material.dart';

class DotMatrix extends StatefulWidget {
  final List<Color> pixels;
  final bool showGrid;
  final Function? onTap;
  final int crossAxisCount = 8;

  const DotMatrix(
      {Key? key, required this.pixels, this.showGrid = false, this.onTap})
      : super(key: key);

  @override
  _DotMatrixState createState() => _DotMatrixState();
}

class _DotMatrixState extends State<DotMatrix> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            onTapDown: (TapDownDetails details) =>
                widget.onTap != null ? _onTapDown(details, constraints) : null,
            child: CustomPaint(
              size: Size(
                constraints.maxWidth,
                constraints.maxHeight,
              ),
              painter: DotMatrixPainter(
                  pixels: widget.pixels,
                  constraints: constraints,
                  crossAxisCount: widget.crossAxisCount,
                  showGrid: widget.showGrid),
            ),
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    var clickOffset = box.globalToLocal(details.globalPosition);

    final dx = clickOffset.dx;
    final dy = clickOffset.dy;
    final pixelSize = constraints.maxWidth / widget.crossAxisCount;

    final tapedRow = (dx / pixelSize).floor();
    final tapedColumn = (dy / pixelSize).floor();
    var clickedIndex = tapedColumn * widget.crossAxisCount + tapedRow;
    widget.onTap!(clickedIndex);
  }
}

class DotMatrixPainter extends CustomPainter {
  final Paint painter = Paint();
  final int crossAxisCount;
  late double pixelSize;
  final List<Color> pixels;
  final BoxConstraints constraints;
  final bool showGrid;

  DotMatrixPainter(
      {required this.pixels,
      required this.constraints,
      required this.crossAxisCount,
      this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    pixelSize = constraints.maxWidth / crossAxisCount;
    pixels.asMap().forEach((index, pixel) {
      painter.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % crossAxisCount).floor().toDouble() * pixelSize,
            (index / crossAxisCount).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          painter);
    });

    if (showGrid) {
      painter.color = Colors.blueGrey;
      for (int index = 1; index < crossAxisCount; index++) {
        canvas.drawLine(
            Offset((index % crossAxisCount).floor().toDouble() * pixelSize, 0),
            Offset((index % crossAxisCount).floor().toDouble() * pixelSize,
                size.height),
            painter);

        canvas.drawLine(
            Offset(0, (index % crossAxisCount).floor().toDouble() * pixelSize),
            Offset(size.width,
                (index % crossAxisCount).floor().toDouble() * pixelSize),
            painter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
