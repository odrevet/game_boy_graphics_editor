import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_tile_converter.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_dimensions_dropdown.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';
import '../../models/download_stub.dart' if (dart.library.html) '../../models/download.dart';
import '../../models/file_utils.dart';

class TilesAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Function loadTileFromFilePicker;
  final Function saveGraphics;

  const TilesAppBar({
    this.preferredSize = const Size.fromHeight(50.0),
    Key? key,
    required this.loadTileFromFilePicker,
    required this.saveGraphics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    actions = [
      IconButton(
          onPressed:
              context.read<MetaTileCubit>().canUndo ? context.read<MetaTileCubit>().undo : null,
          icon: const Icon(Icons.undo)),
      IconButton(
          onPressed:
              context.read<MetaTileCubit>().canRedo ? context.read<MetaTileCubit>().redo : null,
          icon: const Icon(Icons.redo)),
      const VerticalDivider(),
      IconButton(
        icon: Icon(context.read<AppStateCubit>().state.floodMode ? Icons.waves : Icons.edit),
        tooltip: context.read<AppStateCubit>().state.floodMode ? 'Flood fill' : 'Draw',
        onPressed: () => context.read<AppStateCubit>().toggleFloodMode(),
      ),
      const VerticalDivider(),
      const TileDimensionDropdown(),
      IconButton(
        icon:
            Icon(context.read<AppStateCubit>().state.showGridTile ? Icons.grid_on : Icons.grid_off),
        tooltip: '${context.read<AppStateCubit>().state.showGridTile ? 'Hide' : 'Show'} grid',
        onPressed: () => context.read<AppStateCubit>().toggleGridTile(),
      ),
      const VerticalDivider(),
      kIsWeb
          ? IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download',
              onPressed: () {
                download(
                    GBDKTileConverter().toHeader(context.read<MetaTileCubit>().state,
                        context.read<AppStateCubit>().state.tileName),
                    '${context.read<AppStateCubit>().state.tileName}.h');
                download(
                    GBDKTileConverter().toSource(context.read<MetaTileCubit>().state,
                        context.read<AppStateCubit>().state.tileName),
                    '${context.read<AppStateCubit>().state.tileName}.c');
              })
          : IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save tiles as',
              onPressed: () => saveGraphics(),
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
              final bool hasLoaded = loadTileFromFilePicker(result);
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
                builder: (BuildContext alertDialogContext) => AlertDialog(
                      title: const Text('Tile Settings'),
                      content: SizedBox(
                        height: 200,
                        width: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text("Tile properties"),
                              TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('^[a-zA-Z0-9_]*')),
                                  ],
                                  decoration: const InputDecoration(labelText: 'Name'),
                                  key: Key(context.read<AppStateCubit>().state.tileName),
                                  initialValue: context.read<AppStateCubit>().state.tileName,
                                  onChanged: (text) =>
                                      context.read<AppStateCubit>().setTileName(text)),
                              const Text("Display"),
                              TextButton(
                                  onPressed: () => context.read<AppStateCubit>().toggleColorSet(),
                                  child: const Text("DMG / Pocket")),
                              TextButton(
                                  onPressed: () => context
                                      .read<AppStateCubit>()
                                      .toggleDisplayExportPreviewTile(),
                                  child: const Text("Display Export Preview"))
                            ],
                          ),
                        ),
                      ),
                    ));
          },
          icon: const Icon(Icons.settings)),
    ];

    return AppBar(
      title: ElevatedButton.icon(
          onPressed: () => context.read<AppStateCubit>().toggleTileMode(),
          icon: const Icon(Icons.wallpaper),
          label: const Text('Tile')),
      actions: actions,
    );
  }
}
