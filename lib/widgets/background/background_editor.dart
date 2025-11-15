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
    final appState = context.read<AppStateCubit>().state;
    final backgroundState = context.read<BackgroundCubit>().state;
    final metaTileState = context.read<MetaTileCubit>().state;

    return BlocBuilder<BackgroundCubit, Background>(
      builder: (context, background) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackgroundToolbar(),
            Expanded(
              child: GestureDetector(
                onSecondaryTapDown: (details) {
                  // Show context menu on right-click
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  showMenu(
                    context: context,
                    position: RelativeRect.fromRect(
                      details.globalPosition & Size.zero,
                      Offset.zero & overlay.size,
                    ),
                    items: [
                      PopupMenuItem(
                        value: 'insert_row_above',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, size: 18),
                            SizedBox(width: 8),
                            Text('Insert Row Above'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'insert_row_below',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, size: 18),
                            SizedBox(width: 8),
                            Text('Insert Row Below'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'insert_column_left',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back, size: 18),
                            SizedBox(width: 8),
                            Text('Insert Column Left'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'insert_column_right',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward, size: 18),
                            SizedBox(width: 8),
                            Text('Insert Column Right'),
                          ],
                        ),
                      ),
                      if (background.height > 1)
                        PopupMenuItem(
                          value: 'remove_row',
                          child: Row(
                            children: [
                              Icon(Icons.remove, size: 18),
                              SizedBox(width: 8),
                              Text('Remove Current Row'),
                            ],
                          ),
                        ),
                      if (background.width > 1)
                        PopupMenuItem(
                          value: 'remove_column',
                          child: Row(
                            children: [
                              Icon(Icons.remove, size: 18),
                              SizedBox(width: 8),
                              Text('Remove Current Column'),
                            ],
                          ),
                        ),
                    ],
                  ).then((value) {
                    // Handle menu selection
                    switch (value) {
                      case 'insert_row_above':
                        _insertRowAbove(context);
                        break;
                      case 'insert_row_below':
                        _insertRowBelow(context);
                        break;
                      case 'insert_column_left':
                        _insertColumnLeft(context);
                        break;
                      case 'insert_column_right':
                        _insertColumnRight(context);
                        break;
                      case 'remove_row':
                        _removeRow(context);
                        break;
                      case 'remove_column':
                        _removeColumn(context);
                        break;
                    }
                  });
                },
                child: BackgroundGrid(
                  hoverTileIndexX: hoverTileIndexX,
                  hoverTileIndexY: hoverTileIndexY,
                  background: backgroundState,
                  tileOrigin: backgroundState.tileOrigin,
                  showGrid: appState.showGridBackground,
                  metaTile: metaTileState,
                  cellSize: 40 * appState.zoomBackground,
                  lock: context.read<AppStateCubit>().state.lockScrollBackground,
                  onTap: (index) => {
                    if (!appState.lockScrollBackground)
                      {draw(context, index, backgroundState)},
                  },
                  onHover: (x, y) => setState(() {
                    hoverTileIndexX = x;
                    hoverTileIndexY = y;
                  }),
                ),
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

  void _insertRowAbove(BuildContext context) {
    context.read<BackgroundCubit>().insertRow(hoverTileIndexY, 0);
  }

  void _insertRowBelow(BuildContext context) {
    context.read<BackgroundCubit>().insertRow(hoverTileIndexY + 1, 0);
  }

  void _insertColumnLeft(BuildContext context) {
    context.read<BackgroundCubit>().insertCol(hoverTileIndexX, 0);
  }

  void _insertColumnRight(BuildContext context) {
    context.read<BackgroundCubit>().insertCol(hoverTileIndexX + 1, 0);
  }

  void _removeRow(BuildContext context) {
    context.read<BackgroundCubit>().deleteRow(hoverTileIndexY);
  }

  void _removeColumn(BuildContext context) {
    context.read<BackgroundCubit>().deleteCol(hoverTileIndexX);
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
