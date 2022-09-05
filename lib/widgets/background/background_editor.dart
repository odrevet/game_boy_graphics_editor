import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/background/background_grid.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_list_view.dart';

import '../../models/background.dart';
import '../../models/meta_tile.dart';

class BackgroundEditor extends StatefulWidget {
  final MetaTile tiles;
  final int selectedTileIndex;
  final Function? onTapTileListView;
  final bool showGrid;
  final List<Color> colorSet;

  const BackgroundEditor(
      {Key? key,
      required this.tiles,
      required this.selectedTileIndex,
      required this.colorSet,
      this.onTapTileListView,
      this.showGrid = false})
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
          selectedTile: widget.selectedTileIndex,
          onTap: (index) =>
              widget.onTapTileListView != null ? widget.onTapTileListView!(index) : null),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ContextMenuArea(
          builder: (context) => [
            ListTile(
              title: const Text('Insert column before'),
              onTap: () {
                context.read<BackgroundCubit>().insertCol(hoverTileIndex, widget.selectedTileIndex);
                /*setState(() {
                  widget.background.insertCol(
                      hoverTileIndex % widget.background.width, widget.selectedTileIndex);
                });*/
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Delete column'),
              onTap: () {
                /*setState(() {
                  widget.background.deleteCol(hoverTileIndex % widget.background.width);
                });*/
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Insert row before'),
              onTap: () {
                /*setState(() {
                  widget.background.insertRow(
                      hoverTileIndex ~/ widget.background.width, widget.selectedTileIndex);
                });*/
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Remove row'),
              onTap: () {
                /*setState(() {
                  widget.background.deleteRow(hoverTileIndex ~/ widget.background.width);
                });*/
                Navigator.of(context).pop();
              },
            )
          ],
          child: BackgroundGrid(
            background: context.read<BackgroundCubit>().state,
            colorSet: widget.colorSet,
            showGrid: widget.showGrid,
            metaTile: widget.tiles,
            onTap: (index) => setState(() {
              //widget.background.data[index] = widget.selectedTileIndex;
            }),
            onHover: (index) => setState(() {
              hoverTileIndex = index;
            }),
          ),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            /*TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              key: Key(widget.background.name),
              initialValue: widget.background.name,
              onChanged: (text) => setState(() {
                widget.background.name = text;
              }),
            ),*/
            /*Row(
              children: [
                Text("Width ${widget.background.width}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Column',
                    onPressed: () => setState(() {
                          widget.background.insertCol(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Column',
                    onPressed: () => widget.background.width > 1
                        ? setState(() {
                            widget.background.deleteCol(0);
                          })
                        : null),
              ],
            ),
            Row(
              children: [
                Text("Height ${widget.background.height}"),
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Row',
                    onPressed: () => setState(() {
                          widget.background.insertRow(0, 0);
                        })),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Remove Row',
                    onPressed: () => widget.background.height > 1
                        ? setState(() {
                            widget.background.deleteRow(0);
                          })
                        : null),
              ],
            ), */
            /*Expanded(
                child: SingleChildScrollView(
              child: SourceDisplay(graphics: widget.background),
            )),*/
          ],
        ),
      )
    ]);
  }
}
