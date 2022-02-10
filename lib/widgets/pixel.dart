import 'package:flutter/material.dart';

class PixelWidget extends StatefulWidget {
  final int intensity;
  final colors = const [Color(0xff9bbc0f), Color(0xff8bac0f), Color(0xff306230), Color(0xff0f380f)];

  const PixelWidget({this.intensity = 0, Key? key}) : super(key: key);

  @override
  _PixelWidgetState createState() => _PixelWidgetState();
}

class _PixelWidgetState extends State<PixelWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.colors[widget.intensity],
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
