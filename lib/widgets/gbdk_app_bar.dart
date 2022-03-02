import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';

import '../background.dart';
import '../file_utils.dart';
import 'intensity_button.dart';

class GBDKAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Function setIntensity;
  final int selectedIntensity;
  final VoidCallback addTile;
  final VoidCallback setTileMode;
  final VoidCallback toggleGrid;
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
      required this.setTileMode,
      required this.toggleGrid,
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
          icon: const Icon(Icons.grid_on),
          tooltip: 'Show/Hide grid',
          onPressed: toggleGrid,
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
          icon: const Icon(Icons.save),
          tooltip: kIsWeb
              ? 'Save is not available for web'
              : 'Save tiles source file',
          onPressed: kIsWeb ? null : () => saveFile(tiles.toSource()),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((source) => source != null
                ? setTileFromSource(source)
                : null)
          },
        )
      ];
    } else {
      actions = [
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: kIsWeb
              ? 'Save is not available for web'
              : 'Save background source file',
          onPressed: kIsWeb ? null : () => saveFile(background.toSource()),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((source) => source != null
                ? setBackgroundFromSource(source)
                : null)
          },
        )
      ];
    }

    actions.add(_setTileModeButton());

    return AppBar(
      title: Text(tileMode
          ? "${tiles.name} tile #$selectedTileIndexTile selected. ${tiles.count} tile(s) total"
          : "${background.name} tile #$selectedTileIndexBackground selected"),
      actions: actions,
    );
  }

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: Icon(tileMode == true ? Icons.sports_martial_arts : Icons.map),
        label: Text(tileMode == true ? 'tile' : 'Map'));
  }
}
