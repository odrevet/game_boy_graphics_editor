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
                  pixelSize: constraints.maxWidth / widget.crossAxisCount,
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
    final pixelSize = constraints.maxWidth / widget.crossAxisCount;
    final tapedRow = (clickOffset.dx / pixelSize).floor();
    final tapedColumn = (clickOffset.dy / pixelSize).floor();
    widget.onTap!(tapedColumn * widget.crossAxisCount + tapedRow);
  }
}

class DotMatrixPainter extends CustomPainter {
  final int crossAxisCount;
  final double pixelSize;
  final List<Color> pixels;
  final bool showGrid;

  DotMatrixPainter(
      {required this.pixels,
      required this.pixelSize,
      required this.crossAxisCount,
      this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    pixels.asMap().forEach((index, pixel) {
      paint.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % crossAxisCount).floor().toDouble() * pixelSize,
            (index / crossAxisCount).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint);
    });

    if (showGrid) {
      paint.color = Colors.blueGrey;
      for (int index = 1; index <= crossAxisCount; index++) {
        canvas.drawLine(
            Offset((index % crossAxisCount).floor().toDouble() * pixelSize, 0),
            Offset((index % crossAxisCount).floor().toDouble() * pixelSize,
                size.height),
            paint);

        canvas.drawLine(
            Offset(0, (index % crossAxisCount).floor().toDouble() * pixelSize),
            Offset(size.width,
                (index % crossAxisCount).floor().toDouble() * pixelSize),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
