import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';


class BackgroundToolbar extends StatelessWidget {
  const BackgroundToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const VerticalDivider(),
        IconButton(
            onPressed: context.read<AppStateCubit>().state.zoomBackground >= 0.4
                ? context.read<AppStateCubit>().decreaseZoomBackground
                : null,
            icon: const Icon(Icons.zoom_out)),
        IconButton(
            onPressed: context.read<AppStateCubit>().state.zoomBackground <= 0.8
                ? context.read<AppStateCubit>().increaseZoomBackground
                : null,
            icon: const Icon(Icons.zoom_in)),
      ],
    );
  }
}
