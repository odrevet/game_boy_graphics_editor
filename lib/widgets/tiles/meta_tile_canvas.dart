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
                if (isHover && appState.drawModeTile == DrawMode.single) {
                  draw(details, constraints, appState.intensity,
                      appState.drawModeTile);
                }
              },
              onTapDown: (TapDownDetails details) {
                if (isHover) {
                  draw(details, constraints, appState.intensity,
                      appState.drawModeTile);
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
      DrawMode drawMode) {
    var localPosition = details.localPosition;
    final pixelSize =
        constraints.maxWidth / context.read<MetaTileCubit>().state.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();
    int targetColor = context.read<MetaTileCubit>().state.getPixel(
        rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile);

    switch (context.read<AppStateCubit>().state.drawModeTile) {
      case DrawMode.single:
        if (targetColor != intensity) {
          context.read<MetaTileCubit>().setPixel(
              rowIndex,
              colIndex,
              context.read<AppStateCubit>().state.tileIndexTile,
              context.read<AppStateCubit>().state.intensity);
        }
        break;
      case DrawMode.flood:
        if (targetColor != context.read<AppStateCubit>().state.intensity) {
          context.read<MetaTileCubit>().flood(
              rowIndex,
              colIndex,
              context.read<AppStateCubit>().state.tileIndexTile,
              intensity,
              targetColor);
        }
        break;
      case DrawMode.line:
        print('TODO Draw Line');
        break;
      case DrawMode.rectangle:
        print('TODO Draw Rectangle');
        break;
    }
  }

  pickColorAtCursor(dynamic details, BoxConstraints constraints) {
    var metaTile = context.read<MetaTileCubit>().state;
    var localPosition = details.localPosition;
    final pixelSize = constraints.maxWidth / metaTile.width;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();
    int intensityAtCursor = metaTile.getPixel(
        rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile);
    context.read<AppStateCubit>().setIntensity(intensityAtCursor);
  }
}
