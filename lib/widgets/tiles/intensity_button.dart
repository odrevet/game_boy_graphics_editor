import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final List<Color> colorSet;

  const IntensityButton({Key? key, required this.intensity, required this.colorSet})
      : super(key: key);

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.read<AppStateCubit>().setIntensity(intensity),
          child: SizedBox(
            width: 25,
            height: 25,
            child: Container(
                decoration: BoxDecoration(
              color: colorSet[intensity],
              border: Border.all(
                  color: intensity == context.read<AppStateCubit>().state.intensity
                      ? Colors.blue
                      : Colors.black,
                  width: 1),
            )),
          ),
        ),
      );
}
