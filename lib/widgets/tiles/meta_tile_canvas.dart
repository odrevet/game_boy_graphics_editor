import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/app_state.dart';

class MetaTileCanvas extends StatefulWidget {
  const MetaTileCanvas({Key? key}) : super(key: key);

  @override
  State<MetaTileCanvas> createState() => _MetaTileCanvasState();
}

class _MetaTileCanvasState extends State<MetaTileCanvas> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(builder: (context, appState) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => MouseRegion(
          cursor: SystemMouseCursors.precise,
          onEnter: (PointerEvent details) => setState(() => isHover = true),
          onExit: (PointerEvent details) => setState(() {
            isHover = false;
          }),
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              if (isHover && context.read<AppStateCubit>().state.floodMode == false) {
                draw(details, constraints, appState.intensity, appState.floodMode);
              }
            },
            onTapDown: (TapDownDetails details) {
              if (isHover) {
                draw(details, constraints, appState.intensity, appState.floodMode);
              }
            },
            child: MetaTileDisplay(
              tileData: context.read<MetaTileCubit>().state.getTile(appState.tileIndexTile),
            ),
          ),
        ),
      );
    });
  }

  draw(dynamic details, BoxConstraints constraints, int intensity, bool floodMode) {
    var localPosition = details.localPosition;
    final pixelSize = constraints.maxWidth / context.read<MetaTileCubit>().state.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();
    int targetColor = context
        .read<MetaTileCubit>()
        .state
        .getPixel(rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile);

    if (floodMode) {
      if (targetColor != context.read<AppStateCubit>().state.intensity) {
        context.read<MetaTileCubit>().flood(rowIndex, colIndex,
            context.read<AppStateCubit>().state.tileIndexTile, intensity, targetColor);
      }
    } else if (targetColor != intensity) {
      context.read<MetaTileCubit>().setPixel(
          rowIndex,
          colIndex,
          context.read<AppStateCubit>().state.tileIndexTile,
          context.read<AppStateCubit>().state.intensity);
    }
  }
}
