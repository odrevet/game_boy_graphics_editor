import 'package:flutter/material.dart';

class DotMatrix extends StatefulWidget {
  final List<Color> pixels;
  final bool showGrid;
  final Function? onTap;
  final int? onTapParam;
  final int width;
  final int height;

  const DotMatrix(
      {Key? key,
      required this.pixels,
      this.showGrid = false,
      this.onTap,
      this.onTapParam,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  _DotMatrixState createState() => _DotMatrixState();
}

class _DotMatrixState extends State<DotMatrix> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          Widget customPaint = CustomPaint(
            size: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            painter: DotMatrixPainter(
                pixels: widget.pixels,
                pixelSize: constraints.maxWidth / widget.width,
                width: widget.width,
                height: widget.height,
                showGrid: widget.showGrid),
          );

          if (widget.onTap != null) {
            return MouseRegion(
              cursor: SystemMouseCursors.precise,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (TapDownDetails details) =>
                    _onTapDown(details, constraints),
                child: customPaint,
              ),
            );
          } else {
            return customPaint;
          }
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    var clickOffset = details.localPosition;
    final pixelSize = constraints.maxWidth / widget.width;
    final tapedRow = (clickOffset.dx / pixelSize).floor();
    final tapedColumn = (clickOffset.dy / pixelSize).floor();
    widget.onTap!(tapedColumn * widget.width + tapedRow, widget.onTapParam);
  }
}

class DotMatrixPainter extends CustomPainter {
  final int width;
  final int height;
  final double pixelSize;
  final List<Color> pixels;
  final bool showGrid;

  DotMatrixPainter(
      {required this.pixels,
      required this.pixelSize,
      required this.width,
      required this.height,
      this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    pixels.asMap().forEach((index, pixel) {
      paint.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % width).floor().toDouble() * pixelSize,
            (index / width).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint);
    });

    if (showGrid) {
      paint.color = Colors.blueGrey;
      for (int index = 1; index <= width; index++) {
        canvas.drawLine(
            Offset((index % width).floor().toDouble() * pixelSize, 0),
            Offset((index % width).floor().toDouble() * pixelSize, size.height),
            paint);
      }

      for (int index = 1; index <= height; index++) {
        canvas.drawLine(
            Offset(0, (index % height).floor().toDouble() * pixelSize),
            Offset(size.width, (index % height).floor().toDouble() * pixelSize),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
