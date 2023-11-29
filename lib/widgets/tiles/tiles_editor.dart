import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_tile_converter.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_canvas.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_dimensions_dropdown.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/app_state.dart';
import '../background/background_grid.dart';
import '../source_display.dart';
import 'intensity_button.dart';

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
                  var tileData = metaTile.getMetaTile(hoverTileIndex);
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
          Column(
            children: [
              Row(
                children: [
                  ButtonBar(
                    children: [
                      IntensityButton(
                        intensity: 0,
                        colorSet: appState.colorSet,
                      ),
                      IntensityButton(
                        intensity: 1,
                        colorSet: appState.colorSet,
                      ),
                      IntensityButton(
                        intensity: 2,
                        colorSet: appState.colorSet,
                      ),
                      IntensityButton(
                        intensity: 3,
                        colorSet: appState.colorSet,
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  IconButton(
                      onPressed: () => context
                          .read<MetaTileCubit>()
                          .flipVertical(appState.tileIndexTile),
                      icon: const Icon(Icons.flip)),
                  IconButton(
                      onPressed: () => context
                          .read<MetaTileCubit>()
                          .flipHorizontal(appState.tileIndexTile),
                      icon: const RotatedBox(
                        quarterTurns: 1,
                        child: Icon(Icons.flip),
                      )),
                  IconButton(
                      onPressed: () => metaTile.width == metaTile.height
                          ? context
                              .read<MetaTileCubit>()
                              .rotateLeft(appState.tileIndexTile)
                          : null,
                      icon: const Icon(Icons.rotate_left)),
                  IconButton(
                      onPressed: () => metaTile.width == metaTile.height
                          ? context
                              .read<MetaTileCubit>()
                              .rotateRight(appState.tileIndexTile)
                          : null,
                      icon: const Icon(Icons.rotate_right)),
                  const VerticalDivider(),
                  IconButton(
                      onPressed: () => context.read<MetaTileCubit>().upShift(
                          appState.tileIndexTile, appState.tileIndexTile),
                      icon: const Icon(Icons.keyboard_arrow_up_rounded)),
                  IconButton(
                      onPressed: () => context.read<MetaTileCubit>().downShift(
                          appState.tileIndexTile, appState.tileIndexTile),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                  IconButton(
                      onPressed: () => context.read<MetaTileCubit>().leftShift(
                          appState.tileIndexTile, appState.tileIndexTile),
                      icon: const Icon(Icons.keyboard_arrow_left_rounded)),
                  IconButton(
                      onPressed: () => context.read<MetaTileCubit>().rightShift(
                          appState.tileIndexTile, appState.tileIndexTile),
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
                    onPressed: () =>
                        context.read<AppStateCubit>().toggleFloodMode(),
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
                    aspectRatio: metaTile.width / metaTile.height,
                    child: const MetaTileCanvas(),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: BackgroundGrid(
                      background: Background(
                          width: 4, height: 4, fill: appState.tileIndexTile),
                      metaTile: metaTile,
                    ),
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
