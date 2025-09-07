import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';

class IntensityButton extends StatelessWidget {
  final int intensity;
  final List<int> colorSet;

  const IntensityButton({
    super.key,
    required this.intensity,
    required this.colorSet,
  });

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
            color: Color(colorSet[intensity]),
            border: intensity == context.read<AppStateCubit>().state.intensity
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.black, width: 1),
          ),
        ),
      ),
    ),
  );
}
