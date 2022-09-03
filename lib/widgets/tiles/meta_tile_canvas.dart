import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/app_state.dart';
import '../../models/meta_tile.dart';

class MetaTileCanvas extends StatefulWidget {
  const MetaTileCanvas(
      {Key? key})
      : super(key: key);

  @override
  State<MetaTileCanvas> createState() => _MetaTileCanvasState();
}

class _MetaTileCanvasState extends State<MetaTileCanvas> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) {
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
                metaTileIndex: appState.tileIndexTile,
                tileData: appState.getCurrentTile(),
                showGrid: appState.showGridTile,
                colorSet: appState.colorSet,
              ),
            ),
          ),
        );
      }
    );
  }

  draw(dynamic details, BoxConstraints constraints, int intensity, bool floodMode) {
    var localPosition = details.localPosition;
    final pixelSize = constraints.maxWidth / context.read<AppStateCubit>().state.tileWidth;
    final rowIndex = (localPosition.dx / pixelSize).floor();
    final colIndex = (localPosition.dy / pixelSize).floor();

    if (floodMode) {
      int targetColor = 42;//widget.metaTile.getPixel(rowIndex, colIndex, widget.metaTileIndex);
      if (targetColor != context.read<AppStateCubit>().state.intensity) {
        context
            .read<MetaTileCubit>()
            .flood(rowIndex, colIndex, context.read<AppStateCubit>().state.tileIndexTile, intensity, targetColor);
      }
    } else if (true /*|| widget.metaTile.getPixel(rowIndex, colIndex, widget.metaTileIndex) !=
        widget.intensity*/) {
      context.read<AppStateCubit>().setPixel(rowIndex, colIndex);
    }
  }
}
