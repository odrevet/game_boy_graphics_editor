import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_dimensions_dropdown.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/states/app_state.dart' show DrawMode;
import 'intensity_button.dart';

class MetaTileToolbar extends StatelessWidget {
  const MetaTileToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: context
                  .read<MetaTileCubit>()
                  .canUndo
                  ? context
                  .read<MetaTileCubit>()
                  .undo
                  : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              onPressed: context
                  .read<MetaTileCubit>()
                  .canRedo
                  ? context
                  .read<MetaTileCubit>()
                  .redo
                  : null,
              icon: const Icon(Icons.redo),
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: context
                  .read<AppStateCubit>()
                  .state
                  .zoomTile >= 0.4
                  ? context
                  .read<AppStateCubit>()
                  .decreaseZoomTile
                  : null,
              icon: const Icon(Icons.zoom_out),
            ),
            IconButton(
              onPressed: context
                  .read<AppStateCubit>()
                  .state
                  .zoomTile <= 0.8
                  ? context
                  .read<AppStateCubit>()
                  .increaseZoomTile
                  : null,
              icon: const Icon(Icons.zoom_in),
            ),
            const VerticalDivider(),
            DrawModeDropdown(),
            const VerticalDivider(),
            const TileDimensionDropdown(),
            const VerticalDivider(),
          ],
        ),
        Row(
          children: [
            OverflowBar(
              children: [
                IntensityButton(
                  intensity: 0,
                  colorSet: context
                      .read<AppStateCubit>()
                      .state
                      .colorSet,
                ),
                IntensityButton(
                  intensity: 1,
                  colorSet: context
                      .read<AppStateCubit>()
                      .state
                      .colorSet,
                ),
                IntensityButton(
                  intensity: 2,
                  colorSet: context
                      .read<AppStateCubit>()
                      .state
                      .colorSet,
                ),
                IntensityButton(
                  intensity: 3,
                  colorSet: context
                      .read<AppStateCubit>()
                      .state
                      .colorSet,
                ),
              ],
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().flipVertical(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const Icon(Icons.flip),
            ),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().flipHorizontal(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const RotatedBox(quarterTurns: 1, child: Icon(Icons.flip)),
            ),
            IconButton(
              onPressed: () =>
              context
                  .read<MetaTileCubit>()
                  .state
                  .width ==
                  context
                      .read<MetaTileCubit>()
                      .state
                      .height
                  ? context.read<MetaTileCubit>().rotateLeft(
                context
                    .read<AppStateCubit>()
                    .state
                    .tileIndexTile,
              )
                  : null,
              icon: const Icon(Icons.rotate_left),
            ),
            IconButton(
              onPressed: () =>
              context
                  .read<MetaTileCubit>()
                  .state
                  .width ==
                  context
                      .read<MetaTileCubit>()
                      .state
                      .height
                  ? context.read<MetaTileCubit>().rotateRight(
                context
                    .read<AppStateCubit>()
                    .state
                    .tileIndexTile,
              )
                  : null,
              icon: const Icon(Icons.rotate_right),
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().upShift(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().downShift(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().leftShift(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const Icon(Icons.keyboard_arrow_left_rounded),
            ),
            IconButton(
              onPressed: () =>
                  context.read<MetaTileCubit>().rightShift(
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                    context
                        .read<AppStateCubit>()
                        .state
                        .tileIndexTile,
                  ),
              icon: const Icon(Icons.keyboard_arrow_right_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class DrawModeDropdown extends StatelessWidget {
  const DrawModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DrawMode>(
      value: context
          .read<AppStateCubit>()
          .state
          .drawModeTile,
      onChanged: (DrawMode? drawMode) {
        context.read<AppStateCubit>().setDrawModeTile(drawMode!);
      },
      items: DrawMode.values.map((DrawMode mode) {
        return DropdownMenuItem<DrawMode>(
          value: mode,
          child: Row(
            children: [
              _getIconForDrawMode(mode),
              // Adding icon here
              const SizedBox(width: 8),
              // Adjust the spacing between icon and text
              Text(mode
                  .toString()
                  .split('.')
                  .last),
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
