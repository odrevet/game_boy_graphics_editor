import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_grid.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../cubits/app_state_cubit.dart';
import '../../models/meta_tile.dart';
import '../source_display.dart';

class BackgroundEditor extends StatefulWidget {
  final MetaTile tiles;
  final Function? onTapTileListView;
  final bool showGrid;

  const BackgroundEditor(
      {Key? key, required this.tiles, this.onTapTileListView, this.showGrid = false})
      : super(key: key);

  @override
  State<BackgroundEditor> createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
  int hoverTileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      MetaTileListView(
          selectedTile: context.read<AppStateCubit>().state.tileIndexBackground,
          onTap: (index) =>
              widget.onTapTileListView != null ? widget.onTapTileListView!(index) : null),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ContextMenuArea(
          builder: (contextMenuArea) => [
            ListTile(
              title: const Text('Insert column before'),
              onTap: () {
                context.read<BackgroundCubit>().insertCol(
                    hoverTileIndex, context.read<AppStateCubit>().state.tileIndexBackground);
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
                    hoverTileIndex, context.read<AppStateCubit>().state.tileIndexBackground);
                Navigator.of(contextMenuArea).pop();
              },
            ),
            ListTile(
              title: const Text('Remove row'),
              onTap: () {
                context.read<BackgroundCubit>().insertRow(
                    hoverTileIndex, context.read<AppStateCubit>().state.tileIndexBackground);
                Navigator.of(contextMenuArea).pop();
              },
            )
          ],
          child: BackgroundGrid(
            background: context.read<BackgroundCubit>().state,
            showGrid: widget.showGrid,
            metaTile: widget.tiles,
            onTap: (index) => context.read<BackgroundCubit>().setTileIndex(
                index % context.read<BackgroundCubit>().state.width,
                index ~/ context.read<BackgroundCubit>().state.width,
                context.read<AppStateCubit>().state.tileIndexBackground),
            onHover: (index) => setState(() {
              hoverTileIndex = index;
            }),
          ),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              initialValue: context.read<AppStateCubit>().state.backgroundName,
              onChanged: (text) => setState(() {
                context.read<AppStateCubit>().setBackgroundName(text);
              }),
            ),
            Row(
              children: [
                Text("Width ${context.read<BackgroundCubit>().state.width}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Column',
                    onPressed: () => setState(() {
                          context.read<BackgroundCubit>().insertCol(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Column',
                    onPressed: () => context.read<BackgroundCubit>().state.width > 1
                        ? setState(() {
                            context.read<BackgroundCubit>().deleteCol(0);
                          })
                        : null),
              ],
            ),
            Row(
              children: [
                Text("Height ${context.read<BackgroundCubit>().state.height}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Row',
                    onPressed: () => setState(() {
                          context.read<BackgroundCubit>().insertRow(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Row',
                    onPressed: () => context.read<BackgroundCubit>().state.height > 1
                        ? setState(() {
                            context.read<BackgroundCubit>().deleteRow(0);
                          })
                        : null),
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: SourceDisplay(
                graphics: context.read<BackgroundCubit>().state,
                name: context.read<AppStateCubit>().state.backgroundName,
                sourceConverter: GBDKBackgroundConverter(),
              ),
            )),
          ],
        ),
      )
    ]);
  }
}
