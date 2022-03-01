import 'package:flutter/material.dart';

import '../colors.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final int selectedIntensity;
  final Function onPressed;

  const IntensityButton(
      {Key? key,
      required this.intensity,
      required this.onPressed,
      required this.selectedIntensity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconButton = IconButton(
        icon: Icon(Icons.stop, color: colors[intensity]),
        onPressed: () => onPressed(intensity));

    if (intensity == selectedIntensity) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, width: 1),
        ),
        child: iconButton,
      );
    }

    return iconButton;
  }
}
