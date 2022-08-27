import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/background.dart';
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
  final Background preview;
  final Function setIndex;
  final bool showGrid;
  final bool floodMode;
  final int selectedIndex;
  final List<Color> colorSet;
  final List<int> tileBuffer;

  const TilesEditor({
    Key? key,
    required this.preview,
    required this.setIndex,
    required this.showGrid,
    required this.floodMode,
    required this.selectedIndex,
    required this.colorSet,
    required this.tileBuffer,
  }) : super(key: key);

  @override
  State<TilesEditor> createState() => _TilesEditorState();
}

class _TilesEditorState extends State<TilesEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    var metaTile = context.read<MetaTileCubit>().state;
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) => Row(children: [
        ContextMenuArea(
          builder: (BuildContext contextMenuAreaContext) => [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Insert before"),
              onTap: () {
                context.read<MetaTileCubit>().insert(hoverTileIndex);
                Navigator.pop(contextMenuAreaContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: const Text("Delete"),
              onTap: () {
                context.read<MetaTileCubit>().remove(hoverTileIndex);
                Navigator.pop(contextMenuAreaContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text("Copy"),
              onTap: () {
                setState(() {
                  widget.tileBuffer.clear();
                  for (var i = hoverTileIndex;
                      i < hoverTileIndex + metaTile.nbTilePerMetaTile();
                      i++) {
                    widget.tileBuffer.addAll(metaTile.tileList[i].data);
                  }
                });
                Navigator.pop(contextMenuAreaContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text("Paste"),
              onTap: () {
                context.read<MetaTileCubit>().paste(hoverTileIndex, widget.tileBuffer);
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
                      onPressed: () => context
                          .read<MetaTileCubit>()
                          .insert(metaTile.tileList.length ~/ metaTile.nbTilePerMetaTile())),
                  IconButton(
                      icon: const Icon(Icons.remove),
                      tooltip: 'Remove tile',
                      onPressed: () => context.read<MetaTileCubit>().remove(widget.selectedIndex)),
                ],
              ),
              MetaTileListView(
                  onHover: (index) => setState(() {
                        hoverTileIndex = index;
                      }),
                  onTap: (index) => widget.setIndex(index),
                  metaTile: metaTile,
                  selectedTile: widget.selectedIndex,
                  colorSet: widget.colorSet),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                IntensityButton(
                  intensity: 0,
                  onPressed: (intensity) => context.read<AppStateCubit>().setIntensity(intensity),
                  selectedIntensity: appState.intensity,
                  colorSet: widget.colorSet,
                ),
                IntensityButton(
                  intensity: 1,
                  onPressed: (intensity) => context.read<AppStateCubit>().setIntensity(intensity),
                  selectedIntensity: appState.intensity,
                  colorSet: widget.colorSet,
                ),
                IntensityButton(
                  intensity: 2,
                  onPressed: (intensity) => context.read<AppStateCubit>().setIntensity(intensity),
                  selectedIntensity: appState.intensity,
                  colorSet: widget.colorSet,
                ),
                IntensityButton(
                  intensity: 3,
                  onPressed: (intensity) => context.read<AppStateCubit>().setIntensity(intensity),
                  selectedIntensity: appState.intensity,
                  colorSet: widget.colorSet,
                ),
                const VerticalDivider(),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().flipVertical(appState.metaTileIndexTile),
                    icon: const Icon(Icons.flip)),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().flipHorizontal(appState.metaTileIndexTile),
                    icon: const RotatedBox(
                      quarterTurns: 1,
                      child: Icon(Icons.flip),
                    )),
                IconButton(
                    onPressed: () => metaTile.width == metaTile.height
                        ? context.read<MetaTileCubit>().rotateLeft(appState.metaTileIndexTile)
                        : null,
                    icon: const Icon(Icons.rotate_left)),
                IconButton(
                    onPressed: () => metaTile.width == metaTile.height
                        ? context.read<MetaTileCubit>().rotateRight(appState.metaTileIndexTile)
                        : null,
                    icon: const Icon(Icons.rotate_right)),
                const VerticalDivider(),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().upShift(appState.metaTileIndexTile),
                    icon: const Icon(Icons.keyboard_arrow_up_rounded)),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().downShift(appState.metaTileIndexTile),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().leftShift(appState.metaTileIndexTile),
                    icon: const Icon(Icons.keyboard_arrow_left_rounded)),
                IconButton(
                    onPressed: () =>
                        context.read<MetaTileCubit>().rightShift(appState.metaTileIndexTile),
                    icon: const Icon(Icons.keyboard_arrow_right_rounded)),
                const VerticalDivider(),
                IconButton(
                  icon: Icon(appState.floodMode ? Icons.waves : Icons.edit),
                  tooltip: appState.floodMode ? 'Flood fill' : 'Draw',
                  onPressed: () => context.read<AppStateCubit>().toggleFloodMode(),
                ),
                const VerticalDivider(),
                const TileDimensionDropdown(),
                IconButton(
                  icon: Icon(context.read<AppStateCubit>().state.showGridTile
                      ? Icons.grid_on
                      : Icons.grid_off),
                  tooltip:
                      '${context.read<AppStateCubit>().state.showGridTile ? 'Hide' : 'Show'} grid',
                  onPressed: () => context.read<AppStateCubit>().toggleGridTile(),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.topCenter,
                child: AspectRatio(
                  aspectRatio: metaTile.width / metaTile.height,
                  child: MetaTileCanvas(
                      intensity: appState.intensity,
                      metaTile: metaTile,
                      showGrid: widget.showGrid,
                      floodMode: widget.floodMode,
                      metaTileIndex: widget.selectedIndex,
                      colorSet: widget.colorSet),
                ),
              ),
            )
          ],
        ),
        Expanded(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                key: Key(metaTile.name),
                initialValue: metaTile.name,
                onChanged: (text) => setState(() {
                  metaTile.name = text;
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: BackgroundGrid(
                    background: widget.preview,
                    metaTile: metaTile,
                    colorSet: widget.colorSet,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SourceDisplay(
                    graphics: metaTile,
                  ),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
