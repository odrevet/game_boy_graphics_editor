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
  final bool tileMode;
  final Tiles tiles;
  final Background background;

  const GBDKAppBar(
      {Key? key,
      required this.setIntensity,
      required this.selectedIntensity,
      required this.addTile,
      required this.setTileMode,
      required this.toggleGrid,
      required this.setTileFromSource,
      required this.tileMode,
      required this.tiles,
      required this.background,
      required this.preferredSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
          "${tiles.name} tile #${tiles.index} selected. ${tiles.count} tile(s) total"),
      actions: [
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
          tooltip:
              kIsWeb ? 'Save is not available for web' : 'Save source file',
          onPressed: kIsWeb
              ? null
              : () =>
                  saveFile(tileMode ? tiles.toSource() : background.toSource()),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((nameValues) => nameValues != null
                ? setTileFromSource(nameValues[0], nameValues[1])
                : null)
          },
        ),
        _setTileModeButton()
      ],
    );
  }

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: Icon(tileMode == true ? Icons.sports_martial_arts : Icons.map),
        label: Text(tileMode == true ? 'tile' : 'Map'));
  }
}
