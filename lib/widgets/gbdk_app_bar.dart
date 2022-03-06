import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';

import '../background.dart';
import '../download_stub.dart' if (dart.library.html) '../download.dart';
import '../file_utils.dart';
import 'intensity_button.dart';

class GBDKAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Function setIntensity;
  final int selectedIntensity;
  final VoidCallback addTile;
  final VoidCallback removeTile;
  final VoidCallback setTileMode;
  final VoidCallback toggleGridTile;
  final bool showGridTile;
  final VoidCallback toggleGridBackground;
  final bool showGridBackground;
  final Function setTileFromSource;
  final Function setBackgroundFromSource;
  final bool tileMode;
  final Tiles tiles;
  final Background background;
  final int selectedTileIndexTile;
  final int selectedTileIndexBackground;

  const GBDKAppBar(
      {Key? key,
      required this.setIntensity,
      required this.selectedIntensity,
      required this.addTile,
      required this.removeTile,
      required this.setTileMode,
      required this.toggleGridTile,
      required this.showGridTile,
      required this.toggleGridBackground,
      required this.showGridBackground,
      required this.setTileFromSource,
      required this.setBackgroundFromSource,
      required this.tileMode,
      required this.tiles,
      required this.background,
      required this.selectedTileIndexTile,
      required this.selectedTileIndexBackground,
      this.preferredSize = const Size.fromHeight(50.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    if (tileMode) {
      actions = [
        IconButton(
          icon: Icon(showGridTile == true ? Icons.grid_on : Icons.grid_off),
          tooltip: 'Show/Hide grid',
          onPressed: toggleGridTile,
        ),
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
        IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add tile',
            onPressed: addTile),
        IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Remove tile',
            onPressed: removeTile),
        kIsWeb
            ? IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download',
                onPressed: () {
                  download(tiles.toHeader(), '${tiles.name}.h');
                  download(tiles.toSource(), '${tiles.name}.c');
                })
            : IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () => saveToDirectory(tiles),
              ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then(
                (source) => source != null ? setTileFromSource(source) : null)
          },
        )
      ];
    } else {
      actions = [
        IconButton(
          icon:
              Icon(showGridBackground == true ? Icons.grid_on : Icons.grid_off),
          tooltip: 'Show/Hide grid',
          onPressed: toggleGridBackground,
        ),
        kIsWeb
            ? IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download',
                onPressed: () {
                  download(background.toHeader(), '${background.name}.h');
                  download(background.toSource(), '${background.name}.c');
                })
            : IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () => saveToDirectory(background),
              ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((source) =>
                source != null ? setBackgroundFromSource(source) : null)
          },
        )
      ];
    }

    actions.add(_setTileModeButton());

    return AppBar(
      title: Text(tileMode ? tiles.name : background.name),
      actions: actions,
    );
  }

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: Icon(tileMode == true ? Icons.directions_walk : Icons.wallpaper),
        label: Text(tileMode == true ? 'Tile' : 'Back'));
  }
}
