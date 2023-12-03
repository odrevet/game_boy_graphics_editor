import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_canvas.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_dimensions_dropdown.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import 'intensity_button.dart';

class MetaTileToolbar extends StatelessWidget {
  const MetaTileToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ButtonBar(
              children: [
                IntensityButton(
                  intensity: 0,
                  colorSet: context.read<AppStateCubit>().state.colorSet,
                ),
                IntensityButton(
                  intensity: 1,
                  colorSet: context.read<AppStateCubit>().state.colorSet,
                ),
                IntensityButton(
                  intensity: 2,
                  colorSet: context.read<AppStateCubit>().state.colorSet,
                ),
                IntensityButton(
                  intensity: 3,
                  colorSet: context.read<AppStateCubit>().state.colorSet,
                ),
              ],
            ),
            const VerticalDivider(),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().flipVertical(
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const Icon(Icons.flip)),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().flipHorizontal(
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(Icons.flip),
                )),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().state.width ==
                        context.read<MetaTileCubit>().state.height
                    ? context.read<MetaTileCubit>().rotateLeft(
                        context.read<AppStateCubit>().state.tileIndexTile)
                    : null,
                icon: const Icon(Icons.rotate_left)),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().state.width ==
                        context.read<MetaTileCubit>().state.height
                    ? context.read<MetaTileCubit>().rotateRight(
                        context.read<AppStateCubit>().state.tileIndexTile)
                    : null,
                icon: const Icon(Icons.rotate_right)),
            const VerticalDivider(),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().upShift(
                    context.read<AppStateCubit>().state.tileIndexTile,
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const Icon(Icons.keyboard_arrow_up_rounded)),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().downShift(
                    context.read<AppStateCubit>().state.tileIndexTile,
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const Icon(Icons.keyboard_arrow_down_rounded)),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().leftShift(
                    context.read<AppStateCubit>().state.tileIndexTile,
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const Icon(Icons.keyboard_arrow_left_rounded)),
            IconButton(
                onPressed: () => context.read<MetaTileCubit>().rightShift(
                    context.read<AppStateCubit>().state.tileIndexTile,
                    context.read<AppStateCubit>().state.tileIndexTile),
                icon: const Icon(Icons.keyboard_arrow_right_rounded)),
            const VerticalDivider(),
            IconButton(
                onPressed: context.read<MetaTileCubit>().canUndo
                    ? context.read<MetaTileCubit>().undo
                    : null,
                icon: const Icon(Icons.undo)),
            IconButton(
                onPressed: context.read<MetaTileCubit>().canRedo
                    ? context.read<MetaTileCubit>().redo
                    : null,
                icon: const Icon(Icons.redo)),
            const VerticalDivider(),
            IconButton(
              icon: Icon(context.read<AppStateCubit>().state.floodMode
                  ? Icons.waves
                  : Icons.edit),
              tooltip: context.read<AppStateCubit>().state.floodMode
                  ? 'Flood fill'
                  : 'Draw',
              onPressed: () => context.read<AppStateCubit>().toggleFloodMode(),
            ),
            const VerticalDivider(),
            const TileDimensionDropdown(),
          ],
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: context.read<MetaTileCubit>().state.width /
                  context.read<MetaTileCubit>().state.height,
              child: const MetaTileCanvas(),
            ),
          ),
        )
      ],
    );
  }
}
