import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../download_stub.dart' if (dart.library.html) '../../download.dart';
import '../../file_utils.dart';
import '../../meta_tile.dart';
import '../../meta_tile_cubit.dart';
import '../tiles/intensity_button.dart';

class TilesAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final VoidCallback setTileMode;
  final MetaTile metaTile;
  final bool showGrid;
  final bool floodMode;
  final Function setIntensity;
  final int selectedIntensity;
  final VoidCallback toggleGridTile;
  final VoidCallback toggleFloodMode;
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
    required this.setIntensity,
    required this.selectedIntensity,
    required this.toggleGridTile,
    required this.toggleFloodMode,
    required this.toggleColorSet,
    required this.loadTileFromFilePicker,
    required this.metaTileIndex,
    required this.saveGraphics,
    required this.colorSet,
  }) : super(key: key);

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: const Icon(Icons.wallpaper),
        label: const Text('Tile'));
  }

  Widget _tileDimensionsDropDown(BuildContext context) {
    return DropdownButton<String>(
      value: "${metaTile.width} x ${metaTile.height}",
      onChanged: (String? value) {
        int width = 8;
        int height = 8;
        switch (value) {
          case '8 x 8':
            width = 8;
            height = 8;
            break;
          case '8 x 16':
            width = 8;
            height = 16;
            break;
          case '16 x 16':
            width = 16;
            height = 16;
            break;
          case '32 x 32':
            width = 32;
            height = 32;
            break;
        }

        context.read<MetaTileCubit>().setDimensions(width, height);
      },
      items: <String>['8 x 8', '8 x 16', '16 x 16', '32 x 32']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
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
      IconButton(
          onPressed: () =>
              context.read<MetaTileCubit>().flipVertical(metaTileIndex),
          icon: const Icon(Icons.flip)),
      IconButton(
          onPressed: () =>
              context.read<MetaTileCubit>().flipHorizontal(metaTileIndex),
          icon: const RotatedBox(
            quarterTurns: 1,
            child: Icon(Icons.flip),
          )),
      IconButton(
          onPressed: () => metaTile.width == metaTile.height
              ? context.read<MetaTileCubit>().rotateLeft(metaTileIndex)
              : null,
          icon: const Icon(Icons.rotate_left)),
      IconButton(
          onPressed: () => metaTile.width == metaTile.height
              ? context.read<MetaTileCubit>().rotateRight(metaTileIndex)
              : null,
          icon: const Icon(Icons.rotate_right)),
      const VerticalDivider(),
      IconButton(
          onPressed: () => context.read<MetaTileCubit>().upShift(metaTileIndex),
          icon: const Icon(Icons.keyboard_arrow_up_rounded)),
      IconButton(
          onPressed: () =>
              context.read<MetaTileCubit>().downShift(metaTileIndex),
          icon: const Icon(Icons.keyboard_arrow_down_rounded)),
      IconButton(
          onPressed: () =>
              context.read<MetaTileCubit>().leftShift(metaTileIndex),
          icon: const Icon(Icons.keyboard_arrow_left_rounded)),
      IconButton(
          onPressed: () =>
              context.read<MetaTileCubit>().rightShift(metaTileIndex),
          icon: const Icon(Icons.keyboard_arrow_right_rounded)),
      const VerticalDivider(),
      IconButton(
        icon: Icon(floodMode ? Icons.waves : Icons.edit),
        tooltip: floodMode ? 'Flood fill' : 'Draw',
        onPressed: toggleFloodMode,
      ),
      const VerticalDivider(),
      _tileDimensionsDropDown(context),
      IconButton(
        icon: Icon(showGrid ? Icons.grid_on : Icons.grid_off),
        tooltip: '${showGrid ? 'Hide' : 'Show'} grid',
        onPressed: toggleGridTile,
      ),
      const VerticalDivider(),
      IntensityButton(
        intensity: 0,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
        colorSet: colorSet,
      ),
      IntensityButton(
        intensity: 1,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
        colorSet: colorSet,
      ),
      IntensityButton(
        intensity: 2,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
        colorSet: colorSet,
      ),
      IntensityButton(
        intensity: 3,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
        colorSet: colorSet,
      ),
      const VerticalDivider(),
      IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add tile',
          onPressed: () => context.read<MetaTileCubit>().insert(
              metaTile.tileList.length ~/ metaTile.nbTilePerMetaTile())),
      IconButton(
          icon: const Icon(Icons.remove),
          tooltip: 'Remove tile',
          onPressed: () => context.read<MetaTileCubit>().remove(metaTileIndex)),
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
                        height: 200.0, // Change as per your requirement
                        width: 150.0, // Change as per your requirement
                        child: Row(
                          children: [
                            const Text("ColorSet"),
                            TextButton(
                                onPressed: toggleColorSet,
                                child: const Text("DMG / Pocket"))
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
