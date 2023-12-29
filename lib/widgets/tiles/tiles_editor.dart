import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_tile_converter.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/app_state.dart';
import '../background/background_grid.dart';
import '../source_display.dart';
import 'meta_tile_canvas.dart';
import 'meta_tile_toolbar.dart';

class TilesEditor extends StatefulWidget {
  const TilesEditor({
    super.key,
  });

  @override
  State<TilesEditor> createState() => _TilesEditorState();
}

class _TilesEditorState extends State<TilesEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetaTileCubit, MetaTile>(builder: (context, metaTile) {
      return BlocBuilder<AppStateCubit, AppState>(
        builder: (context, appState) => Row(children: [
          ContextMenuArea(
            builder: (BuildContext contextMenuAreaContext) => [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Insert"),
                onTap: () {
                  {
                    context.read<MetaTileCubit>().addTile(hoverTileIndex);
                    context
                        .read<AppStateCubit>()
                        .setSelectedTileIndex(++hoverTileIndex);
                    Navigator.pop(contextMenuAreaContext);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove),
                title: const Text("Delete"),
                onTap: () {
                  context.read<MetaTileCubit>().removeTile(hoverTileIndex);
                  context
                      .read<AppStateCubit>()
                      .setSelectedTileIndex(--hoverTileIndex);
                  Navigator.pop(contextMenuAreaContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy"),
                onTap: () {
                  var tileData = metaTile.getTileAtIndex(hoverTileIndex);
                  context.read<AppStateCubit>().setTileBuffer(tileData);
                  Navigator.pop(contextMenuAreaContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.paste),
                title: const Text("Paste"),
                onTap: () {
                  context
                      .read<MetaTileCubit>()
                      .setDataAtIndex(hoverTileIndex, appState.tileBuffer);
                  Navigator.pop(contextMenuAreaContext);
                },
              ),
            ],
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Add tile',
                        onPressed: () {
                          int tileIndex =
                              context.read<AppStateCubit>().state.tileIndexTile;
                          context.read<MetaTileCubit>().addTile(tileIndex);
                          context
                              .read<AppStateCubit>()
                              .setSelectedTileIndex(++tileIndex);
                        }),
                    IconButton(
                        icon: const Icon(Icons.remove),
                        tooltip: 'Remove tile',
                        onPressed: () {
                          int tileIndex =
                              context.read<AppStateCubit>().state.tileIndexTile;
                          if (tileIndex > 0) {
                            context.read<MetaTileCubit>().removeTile(tileIndex);
                            context
                                .read<AppStateCubit>()
                                .setSelectedTileIndex(--tileIndex);
                          }
                        }),
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    child: MetaTileListView(
                        selectedTile:
                            context.read<AppStateCubit>().state.tileIndexTile,
                        onHover: (index) => setState(() {
                              hoverTileIndex = index;
                            }),
                        onTap: (index) => context
                            .read<AppStateCubit>()
                            .setSelectedTileIndex(index)),
                  ),
                ),
              ],
            ),
          ),
          // ignore: prefer_const_constructors
          SizedBox(
            width: (MediaQuery.of(context).size.width ~/3) * context.read<AppStateCubit>().state.zoomTile,
            height: (MediaQuery.of(context).size.width ~/ 3) * context.read<AppStateCubit>().state.zoomTile,
            child: const MetaTileCanvas(),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: BackgroundGrid(
                    background: Background(
                        width: 4, height: 4, fill: appState.tileIndexTile),
                    metaTile: metaTile,
                  ),
                ),
                context.read<AppStateCubit>().state.showExportPreviewTile
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SourceDisplay(
                                source: GBDKTileConverter()
                                    .toHeader(metaTile, appState.tileName),
                                name: appState.tileName, extension: '.h',
                                //graphics: metaTile,
                              ),
                              SourceDisplay(
                                source: GBDKTileConverter()
                                    .toSource(metaTile, appState.tileName),
                                name: appState.tileName, extension: '.c',
                                //graphics: metaTile,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          )
        ]),
      );
    });
  }
}
