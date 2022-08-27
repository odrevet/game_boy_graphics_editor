import 'package:flutter/material.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final int selectedIntensity;
  final Function onPressed;
  final List<Color> colorSet;

  const IntensityButton(
      {Key? key,
      required this.intensity,
      required this.onPressed,
      required this.selectedIntensity,
      required this.colorSet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconButton = IconButton(
        icon: Icon(Icons.stop, color: colorSet[intensity]), onPressed: () => onPressed(intensity));

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
