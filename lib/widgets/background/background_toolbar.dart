import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/background_cubit.dart';
import '../../models/app_state.dart' show DrawMode;
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
                IconButton(
                    onPressed: context
                        .read<AppStateCubit>()
                        .toggleLockScrollBackground,
                    icon: Icon(context.read<AppStateCubit>().state.lockScrollBackground ? Icons.lock : Icons.lock_open)),
                DrawModeDropdown()
              ],
            ));
  }
}


class DrawModeDropdown extends StatelessWidget {
  const DrawModeDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DrawMode>(
      value: context.read<AppStateCubit>().state.drawModeBackground,
      onChanged: (DrawMode? drawMode) {
        context.read<AppStateCubit>().setDrawModeBackground(drawMode!);
      },
      items: DrawMode.values.where((mode) => mode != DrawMode.fill).map((DrawMode mode) {
        return DropdownMenuItem<DrawMode>(
          value: mode,
          child: Row(
            children: [
              _getIconForDrawMode(mode), // Adding icon here
              const SizedBox(width: 8), // Adjust the spacing between icon and text
              Text(mode.toString().split('.').last),
            ],
          ),
        );
      }).toList(),
    );
  }

  Icon _getIconForDrawMode(DrawMode mode) {
    IconData iconData;
    switch (mode) {
      case DrawMode.single:
        iconData = Icons.brush;
        break;
      case DrawMode.fill:
        iconData = Icons.format_paint;
        break;
      case DrawMode.line:
        iconData = Icons.line_style;
        break;
      case DrawMode.rectangle:
        iconData = Icons.rectangle;
        break;
    }
    return Icon(iconData);
  }
}

