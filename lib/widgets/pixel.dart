import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/colors.dart';

class PixelWidget extends StatefulWidget {
  final int intensity;

  const PixelWidget({this.intensity = 0, Key? key}) : super(key: key);

  @override
  _PixelWidgetState createState() => _PixelWidgetState();
}

class _PixelWidgetState extends State<PixelWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors[widget.intensity],
      child: Container(
          decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: .2,
        ),
      )),
    );
  }
}
