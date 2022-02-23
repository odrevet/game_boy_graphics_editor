import 'package:flutter/material.dart';

import '../colors.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final Function onPressed;

  const IntensityButton(
      {Key? key, required this.intensity, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.stop, color: colors[intensity]),
        onPressed: () => onPressed(intensity));
  }
}
