import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/app_state.dart';

class MetaTileCanvas extends StatefulWidget {
  const MetaTileCanvas({super.key});

  @override
  State<MetaTileCanvas> createState() => _MetaTileCanvasState();
}

class _MetaTileCanvasState extends State<MetaTileCanvas> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetaTileCubit, MetaTile>(builder: (context, metaTile) {
      return BlocBuilder<AppStateCubit, AppState>(builder: (context, appState) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              MouseRegion(
            cursor: SystemMouseCursors.precise,
            onEnter: (PointerEvent details) => setState(() => isHover = true),
            onExit: (PointerEvent details) => setState(() {
              isHover = false;
            }),
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (isHover && appState.floodMode == false) {
                  draw(details, constraints, appState.intensity,
                      appState.floodMode);
                }
              },
              onTapDown: (TapDownDetails details) {
                if (isHover) {
                  draw(details, constraints, appState.intensity,
                      appState.floodMode);
                }
              },
              onSecondaryTapDown: (TapDownDetails details) {
                if (isHover) {
                  pickColorAtCursor(details, constraints);
                }
              },
              child: MetaTileDisplay(
                showGrid: context.read<AppStateCubit>().state.showGridTile,
                tileData: metaTile.getTileAtIndex(appState.tileIndexTile),
              ),
            ),
          ),
        );
      });
    });
  }

  draw(dynamic details, BoxConstraints constraints, int intensity,
      bool floodMode) {
    var localPosition = details.localPosition;
    final pixelSize =
        constraints.maxWidth / context.read<MetaTileCubit>().state.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();
    int targetColor = context.read<MetaTileCubit>().state.getPixel(
        rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile);

    if (floodMode) {
      if (targetColor != context.read<AppStateCubit>().state.intensity) {
        context.read<MetaTileCubit>().flood(
            rowIndex,
            colIndex,
            context.read<AppStateCubit>().state.tileIndexTile,
            intensity,
            targetColor);
      }
    } else if (targetColor != intensity) {
      context.read<MetaTileCubit>().setPixel(
          rowIndex,
          colIndex,
          context.read<AppStateCubit>().state.tileIndexTile,
          context.read<AppStateCubit>().state.intensity);
    }
  }

  pickColorAtCursor(dynamic details, BoxConstraints constraints) {
    var localPosition = details.localPosition;
    final pixelSize =
        constraints.maxWidth / context.read<MetaTileCubit>().state.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();
    int intensityAtCursor = context.read<MetaTileCubit>().state.getPixel(
        rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile);
    context.read<AppStateCubit>().setIntensity(intensityAtCursor);
  }
}
