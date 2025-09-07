import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_grid.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_toolbar.dart';

import '../../cubits/app_state_cubit.dart';
import '../../models/states/app_state.dart' show DrawMode;

class BackgroundEditor extends StatefulWidget {
  final Function? onTapTileListView;

  const BackgroundEditor({super.key, this.onTapTileListView});

  @override
  State<BackgroundEditor> createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
  int hoverTileIndexX = 0;
  int hoverTileIndexY = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, Background>(
      builder: (context, background) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackgroundToolbar(),
            Expanded(
              child: BackgroundGrid(
                hoverTileIndexX: hoverTileIndexX,
                hoverTileIndexY: hoverTileIndexY,
                background: context.read<BackgroundCubit>().state,
                tileOrigin: context.read<BackgroundCubit>().state.tileOrigin,
                showGrid: context
                    .read<AppStateCubit>()
                    .state
                    .showGridBackground,
                metaTile: context.read<MetaTileCubit>().state,
                cellSize:
                    40 * context.read<AppStateCubit>().state.zoomBackground,
                onTap: (index) {
                  draw(context, index, background);
                },
                onHover: (x, y) => setState(() {
                  hoverTileIndexX = x;
                  hoverTileIndexY = y;
                }),
              ),
            ),
            Row(
              children: [
                Text(
                  " $hoverTileIndexX/${context.read<BackgroundCubit>().state.width - 1}:$hoverTileIndexY/${context.read<BackgroundCubit>().state.height - 1}",
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  draw(BuildContext context, index, background) {
    int tileOrigin = context.read<BackgroundCubit>().state.tileOrigin;
    int tileIndex = context.read<AppStateCubit>().state.tileIndexTile;
    int x = index % background.width;
    int y = index ~/ background.width;

    switch (context.read<AppStateCubit>().state.drawModeBackground) {
      case DrawMode.single:
        context.read<BackgroundCubit>().setTileIndex(
          x,
          y,
          tileIndex + tileOrigin,
        );
        break;
      case DrawMode.fill:
        context.read<BackgroundCubit>().fill(
          tileIndex + tileOrigin,
          x,
          y,
          background.getDataAt(x, y),
        );
        break;
      case DrawMode.line:
        int? from = context.read<AppStateCubit>().state.drawFromBackground;
        if (from == null) {
          context.read<AppStateCubit>().state.drawFromBackground = index;
        } else {
          int xFrom = (from % background.width).toInt();
          int yFrom = from ~/ background.width;

          context.read<BackgroundCubit>().line(
            tileIndex + tileOrigin,
            xFrom,
            yFrom,
            x,
            y,
          );
          context.read<AppStateCubit>().state.drawFromBackground = null;
        }
        break;
      case DrawMode.rectangle:
        if (context.read<AppStateCubit>().state.drawFromBackground == null) {
          context.read<AppStateCubit>().state.drawFromBackground = index;
        } else {
          int xFrom =
              (context.read<AppStateCubit>().state.drawFromBackground! %
                      background.width)
                  .toInt();
          int yFrom =
              context.read<AppStateCubit>().state.drawFromBackground! ~/
              background.width;

          context.read<BackgroundCubit>().rectangle(
            tileIndex + tileOrigin,
            xFrom,
            yFrom,
            x,
            y,
          );
          context.read<AppStateCubit>().state.drawFromBackground = null;
        }
        break;
    }
  }
}
