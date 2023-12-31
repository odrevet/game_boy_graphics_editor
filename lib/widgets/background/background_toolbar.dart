import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/background_cubit.dart';
import '../../models/graphics/background.dart';

class BackgroundToolbar extends StatelessWidget {
  const BackgroundToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, Background>(
        builder: (context, appState) => Row(
              children: [
                const VerticalDivider(),
                IconButton(
                    onPressed: context.read<BackgroundCubit>().canUndo
                        ? context.read<BackgroundCubit>().undo
                        : null,
                    icon: const Icon(Icons.undo)),
                IconButton(
                    onPressed: context.read<BackgroundCubit>().canRedo
                        ? context.read<BackgroundCubit>().redo
                        : null,
                    icon: const Icon(Icons.redo)),
                const VerticalDivider(),
                IconButton(
                    onPressed: context
                                .read<AppStateCubit>()
                                .state
                                .zoomBackground >=
                            0.4
                        ? context.read<AppStateCubit>().decreaseZoomBackground
                        : null,
                    icon: const Icon(Icons.zoom_out)),
                IconButton(
                    onPressed: context
                                .read<AppStateCubit>()
                                .state
                                .zoomBackground <=
                            0.8
                        ? context.read<AppStateCubit>().increaseZoomBackground
                        : null,
                    icon: const Icon(Icons.zoom_in)),
              ],
            ));
  }
}
