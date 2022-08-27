import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/meta_tile_cubit.dart';
import '../../models/download_stub.dart' if (dart.library.html) '../../download.dart';
import '../../models/file_utils.dart';
import '../../models/meta_tile.dart';

class TilesAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final VoidCallback setTileMode;
  final MetaTile metaTile;
  final bool showGrid;
  final bool floodMode;
  final int selectedIntensity;
  final VoidCallback toggleGridTile;
  final VoidCallback toggleColorSet;
  final Function loadTileFromFilePicker;
  final Function saveGraphics;
  final int metaTileIndex;
  final List<Color> colorSet;

  const TilesAppBar({
    this.preferredSize = const Size.fromHeight(50.0),
    Key? key,
    required this.metaTile,
    required this.setTileMode,
    required this.showGrid,
    required this.floodMode,
    required this.selectedIntensity,
    required this.toggleGridTile,
    required this.toggleColorSet,
    required this.loadTileFromFilePicker,
    required this.metaTileIndex,
    required this.saveGraphics,
    required this.colorSet,
  }) : super(key: key);

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode, icon: const Icon(Icons.wallpaper), label: const Text('Tile'));
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    actions = [
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
      kIsWeb
          ? IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download',
              onPressed: () {
                download(metaTile.toHeader(), '${metaTile.name}.h');
                download(metaTile.toSource(), '${metaTile.name}.c');
              })
          : IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save tiles as',
              onPressed: () => saveGraphics(metaTile, context),
            ),
      IconButton(
        icon: const Icon(Icons.folder_open),
        tooltip: 'Load tiles from file',
        onPressed: () => {
          selectFile(['c', 'png']).then((result) {
            late SnackBar snackBar;
            if (result == null) {
              snackBar = const SnackBar(
                content: Text("Not loaded"),
              );
            } else {
              final bool hasLoaded = loadTileFromFilePicker(result, metaTile);
              snackBar = SnackBar(
                content: Text(hasLoaded ? "Data loaded" : "Data not loaded"),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          })
        },
      ),
      IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Settings'),
                      content: SizedBox(
                        height: 200.0,
                        width: 150.0,
                        child: Row(
                          children: [
                            const Text("ColorSet"),
                            TextButton(onPressed: toggleColorSet, child: const Text("DMG / Pocket"))
                          ],
                        ),
                      ),
                    ));
          },
          icon: const Icon(Icons.settings)),
    ];

    return AppBar(
      title: _setTileModeButton(),
      actions: actions,
    );
  }
}
