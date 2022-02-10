import 'package:flutter/material.dart';
import 'pixel.dart';

class PixelGridWidget extends StatefulWidget {
  final List intensity;

  const PixelGridWidget({Key? key, required this.intensity}) : super(key: key);

  @override
  _PixelGridWidgetState createState() => _PixelGridWidgetState();
}

class _PixelGridWidgetState extends State<PixelGridWidget> {
  int spriteSize = 8;


  Widget _buildEditor(BuildContext context, int index) {
    return GestureDetector(
      child: GridTile(
        child: GestureDetector(
          onTap: () => setState(() {
            if (widget.intensity[index] == 3) {
              widget.intensity[index] = 0;
            } else {
              widget.intensity[index] += 1;
            }
          }),
          child: PixelWidget(intensity: widget.intensity[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: _buildEditor,
        itemCount: spriteSize * spriteSize,
      ),
    );
  }
}
