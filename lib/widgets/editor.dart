import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/states/app_state.dart';
import 'background/background_editor.dart';
import 'background/background_grid.dart';
import 'tiles/meta_tile_canvas.dart';
import 'tiles/meta_tile_toolbar.dart';

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int hoverTileIndex = 0;

  Widget _buildMetaTileCanvasWithAspectRatio(
    BuildContext context,
    MetaTile metaTile,
    AppState appState,
  ) {
    // Calculate aspect ratio
    final double aspectRatio = metaTile.width / metaTile.height;

    // Base size for the canvas
    final double baseSize =
        (MediaQuery.of(context).size.width ~/ 3) * appState.zoomTile.toDouble();

    // Calculate dimensions maintaining aspect ratio
    double canvasWidth, canvasHeight;

    if (aspectRatio >= 1.0) {
      // Width >= Height: constrain by width
      canvasWidth = baseSize;
      canvasHeight = baseSize / aspectRatio;
    } else {
      // Height > Width: constrain by height
      canvasHeight = baseSize;
      canvasWidth = baseSize * aspectRatio;
    }

    return Container(
      width: canvasWidth,
      height: canvasHeight,
      child: const MetaTileCanvas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetaTileCubit, MetaTile>(
      builder: (context, metaTile) {
        return BlocBuilder<AppStateCubit, AppState>(
          builder: (context, appState) => Row(
            children: [
              ContextMenuArea(
                builder: (BuildContext contextMenuAreaContext) => [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Insert"),
                    onTap: () {
                      {
                        context.read<MetaTileCubit>().addTile(hoverTileIndex);
                        context.read<AppStateCubit>().setSelectedTileIndex(
                          ++hoverTileIndex,
                        );
                        Navigator.pop(contextMenuAreaContext);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.remove),
                    title: const Text("Delete"),
                    onTap: () {
                      int tileIndex = context
                          .read<AppStateCubit>()
                          .state
                          .tileIndexTile;

                      // Get total number of tiles
                      int totalTiles = context.read<MetaTileCubit>().state.data.length ~/
                          context.read<MetaTileCubit>().state.nbPixel;

                      // Only allow removal if more than 1 tile exists
                      if (totalTiles > 1) {
                        context.read<MetaTileCubit>().removeTile(tileIndex);

                        // Adjust selected index if we removed the last tile
                        if (tileIndex >= totalTiles - 1) {
                          context.read<AppStateCubit>().setSelectedTileIndex(tileIndex - 1);
                        }
                        // If we removed the first tile, keep index at 0
                        else if (tileIndex == 0) {
                          context.read<AppStateCubit>().setSelectedTileIndex(0);
                        }
                      }
                      else{
                        context.read<MetaTileCubit>().clearTile(0);
                      }

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
                      context.read<MetaTileCubit>().setDataAtIndex(
                        hoverTileIndex,
                        appState.tileBuffer,
                      );
                      Navigator.pop(contextMenuAreaContext);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text("Clear"),
                    onTap: () {
                      int tileIndex = context
                          .read<AppStateCubit>()
                          .state
                          .tileIndexTile;
                      context.read<MetaTileCubit>().clearTile(tileIndex);
                      Navigator.pop(contextMenuAreaContext);
                    },
                  )
                ],
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add tile',
                          onPressed: () {
                            int tileIndex = context
                                .read<AppStateCubit>()
                                .state
                                .tileIndexTile;
                            context.read<MetaTileCubit>().addTile(tileIndex);
                            context.read<AppStateCubit>().setSelectedTileIndex(
                              ++tileIndex,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          tooltip: 'Remove tile',
                          onPressed: () {
                            int tileIndex = context
                                .read<AppStateCubit>()
                                .state
                                .tileIndexTile;

                            // Get total number of tiles
                            int totalTiles = context.read<MetaTileCubit>().state.data.length ~/
                                context.read<MetaTileCubit>().state.nbPixel;

                            // Only allow removal if more than 1 tile exists
                            if (totalTiles > 1) {
                              context.read<MetaTileCubit>().removeTile(tileIndex);

                              // Adjust selected index if we removed the last tile
                              if (tileIndex >= totalTiles - 1) {
                                context.read<AppStateCubit>().setSelectedTileIndex(tileIndex - 1);
                              }
                              // If we removed the first tile, keep index at 0
                              else if (tileIndex == 0) {
                                context.read<AppStateCubit>().setSelectedTileIndex(0);
                              }
                            }
                            else{
                              context.read<MetaTileCubit>().clearTile(0);
                            }
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: MetaTileListView(
                          selectedTile: context
                              .read<AppStateCubit>()
                              .state
                              .tileIndexTile,
                          onHover: (index) => setState(() {
                            hoverTileIndex = index;
                          }),
                          onTap: (index) => context
                              .read<AppStateCubit>()
                              .setSelectedTileIndex(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ignore: prefer_const_constructors
                  MetaTileToolbar(),
                  _buildMetaTileCanvasWithAspectRatio(
                    context,
                    metaTile,
                    appState,
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: BackgroundGrid(
                      background: Background(
                        width: 4,
                        height: 4,
                        fill: appState.tileIndexTile,
                      ),
                      metaTile: metaTile,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: BackgroundEditor(
                  onTapTileListView: (index) =>
                      context.read<AppStateCubit>().setSelectedTileIndex(index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
