import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../download_stub.dart' if (dart.library.html) '../../download.dart';
import '../../file_utils.dart';
import '../../meta_tile.dart';
import '../tiles/intensity_button.dart';

class TilesAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final VoidCallback setTileMode;
  final MetaTile metaTile;
  final Function setTilesDimensions;
  final bool showGrid;
  final VoidCallback rightShift;
  final VoidCallback leftShift;
  final Function setIntensity;
  final int selectedIntensity;
  final Function addMetaTile;
  final Function removeMetaTile;
  final VoidCallback toggleGridTile;
  final Function setTileFromSource;
  final Function saveGraphics;
  final int metaTileIndex;

  const TilesAppBar({
    this.preferredSize = const Size.fromHeight(50.0),
    Key? key,
    required this.metaTile,
    required this.setTileMode,
    required this.setTilesDimensions,
    required this.showGrid,
    required this.rightShift,
    required this.leftShift,
    required this.setIntensity,
    required this.selectedIntensity,
    required this.addMetaTile,
    required this.removeMetaTile,
    required this.toggleGridTile,
    required this.setTileFromSource,
    required this.metaTileIndex,
    required this.saveGraphics,
  }) : super(key: key);

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: const Icon(Icons.wallpaper),
        label: const Text('Tile'));
  }

  Widget _tileDimensionsDropDown() {
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

        setTilesDimensions(width, height);
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

    actions.add(IconButton(
        onPressed: leftShift,
        icon: const Icon(Icons.keyboard_arrow_left_rounded)));
    actions.add(IconButton(
        onPressed: rightShift,
        icon: const Icon(Icons.keyboard_arrow_right_rounded)));

    actions = [
      ...actions,
      const VerticalDivider(),
      _tileDimensionsDropDown(),
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
      ),
      IntensityButton(
        intensity: 1,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
      ),
      IntensityButton(
        intensity: 2,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
      ),
      IntensityButton(
        intensity: 3,
        onPressed: setIntensity,
        selectedIntensity: selectedIntensity,
      ),
      const VerticalDivider(),
      IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add tile',
          onPressed: () => addMetaTile(
              metaTile.tileList.length ~/ metaTile.nbTilesPerMetaTile())),
      IconButton(
          icon: const Icon(Icons.remove),
          tooltip: 'Remove tile',
          onPressed: () => removeMetaTile(metaTileIndex)),
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
        tooltip: 'Load tiles from C source file',
        onPressed: () => {
          selectFolder().then((source) {
            late SnackBar snackBar;
            if (source == null) {
              snackBar = const SnackBar(
                content: Text("Not loaded"),
              );
            } else {
              bool hasLoaded = setTileFromSource(source);
              snackBar = SnackBar(
                content: Text(hasLoaded ? "Data loaded" : "Data not loaded"),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          })
        },
      ),
      _setTileModeButton()
    ];

    return AppBar(
      title: Text(metaTile.name),
      actions: actions,
    );
  }
}
