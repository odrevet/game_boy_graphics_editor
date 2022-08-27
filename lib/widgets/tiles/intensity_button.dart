import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final List<Color> colorSet;

  const IntensityButton(
      {Key? key, required this.intensity, required this.colorSet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconButton = IconButton(
        icon: Icon(Icons.stop, color: colorSet[intensity]),
        onPressed: () => context.read<AppStateCubit>().setIntensity(intensity));

    if (intensity == context.read<AppStateCubit>().state.intensity) {
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
