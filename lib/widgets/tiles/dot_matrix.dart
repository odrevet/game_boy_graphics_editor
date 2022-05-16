import 'package:flutter/material.dart';

import '../../tile.dart';


class DotMatrix extends StatefulWidget {
  final List<Color> pixels;
  final bool showGrid;

  const DotMatrix({Key? key, required this.pixels, this.showGrid = false})
      : super(key: key);

  @override
  State<DotMatrix> createState() => _DotMatrixState();
}

class _DotMatrixState extends State<DotMatrix> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            CustomPaint(
              painter: DotMatrixPainter(
                  pixels: widget.pixels,
                  pixelSize: constraints.maxWidth / Tile.size,
                  showGrid: widget.showGrid),
            ));
  }
}

class DotMatrixPainter extends CustomPainter {
  final double pixelSize;
  final List<Color> pixels;
  final bool showGrid;

  DotMatrixPainter(
      {required this.pixels, required this.pixelSize, this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    pixels.asMap().forEach((index, pixel) {
      paint.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % Tile.size).floor().toDouble() * pixelSize,
            (index / Tile.size).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint);
    });

    if (showGrid) {
      paint.color = Colors.blueGrey;
      for (int index = 1; index <= Tile.size; index++) {
        canvas.drawLine(
            Offset((index % Tile.size).floor().toDouble() * pixelSize, 0),
            Offset((index % Tile.size).floor().toDouble() * pixelSize,
                size.height),
            paint);
      }

      for (int index = 1; index <= Tile.size; index++) {
        canvas.drawLine(
            Offset(0, (index % Tile.size).floor().toDouble() * pixelSize),
            Offset(
                size.width, (index % Tile.size).floor().toDouble() * pixelSize),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
