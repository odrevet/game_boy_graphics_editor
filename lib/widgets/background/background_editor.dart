import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_grid.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../cubits/app_state_cubit.dart';
import '../../models/graphics/meta_tile.dart';
import '../source_display.dart';

class BackgroundEditor extends StatefulWidget {
  final MetaTile tiles;
  final Function? onTapTileListView;
  final bool showGrid;

  const BackgroundEditor(
      {super.key,
      required this.tiles,
      this.onTapTileListView,
      this.showGrid = false});

  @override
  State<BackgroundEditor> createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, Background>(
        builder: (context, background) {
      return Row(children: [
        SizedBox(
          width: 200,
          child: MetaTileListView(
              selectedTile:
                  context.read<AppStateCubit>().state.tileIndexBackground,
              onTap: (index) => widget.onTapTileListView != null
                  ? widget.onTapTileListView!(index)
                  : null),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ContextMenuArea(
              builder: (contextMenuArea) => [
                ListTile(
                  title: const Text('Insert column before'),
                  onTap: () {
                    context.read<BackgroundCubit>().insertCol(
                        hoverTileIndex,
                        context
                            .read<AppStateCubit>()
                            .state
                            .tileIndexBackground);
                    Navigator.of(contextMenuArea).pop();
                  },
                ),
                ListTile(
                  title: const Text('Delete column'),
                  onTap: () {
                    context.read<BackgroundCubit>().deleteCol(hoverTileIndex);
                    Navigator.of(contextMenuArea).pop();
                  },
                ),
                ListTile(
                  title: const Text('Insert row before'),
                  onTap: () {
                    context.read<BackgroundCubit>().insertRow(
                        hoverTileIndex,
                        context
                            .read<AppStateCubit>()
                            .state
                            .tileIndexBackground);
                    Navigator.of(contextMenuArea).pop();
                  },
                ),
                ListTile(
                  title: const Text('Remove row'),
                  onTap: () {
                    context.read<BackgroundCubit>().insertRow(
                        hoverTileIndex,
                        context
                            .read<AppStateCubit>()
                            .state
                            .tileIndexBackground);
                    Navigator.of(contextMenuArea).pop();
                  },
                )
              ],
              child: BackgroundGrid(
                background: context.read<BackgroundCubit>().state,
                showGrid: widget.showGrid,
                metaTile: widget.tiles,
                onTap: (index) => context.read<BackgroundCubit>().setTileIndex(
                    index % background.width,
                    index ~/ background.width,
                    context.read<AppStateCubit>().state.tileIndexBackground),
                onHover: (index) => setState(() {
                  hoverTileIndex = index;
                }),
              ),
            ),
          ),
        ),
        context.read<AppStateCubit>().state.showExportPreviewBackground
            ? Flexible(
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SourceDisplay(
                            source: GBDKBackgroundConverter().toHeader(
                                background,
                                context
                                    .read<AppStateCubit>()
                                    .state
                                    .backgroundName),
                            name: context
                                .read<AppStateCubit>()
                                .state
                                .backgroundName,
                            extension: '.h',
                          ),
                          SourceDisplay(
                            source: GBDKBackgroundConverter().toSource(
                                background,
                                context
                                    .read<AppStateCubit>()
                                    .state
                                    .backgroundName),
                            name: context
                                .read<AppStateCubit>()
                                .state
                                .backgroundName,
                            extension: '.c',
                          )
                        ],
                      ),
                    )),
                  ],
                ),
              )
            : Container()
      ]);
    });
  }
}
