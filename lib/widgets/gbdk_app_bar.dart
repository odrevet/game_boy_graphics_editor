import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';

import '../file_utils.dart';
import 'intensity_button.dart';

class GBDKAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Function setIntensity;
  final VoidCallback addTile;
  final VoidCallback setTileMode;
  final Function setTileFromSource;
  final bool tileMode;
  final Tiles tiles;

  const GBDKAppBar(
      {Key? key,
      required this.setIntensity,
      required this.addTile,
      required this.setTileMode,
      required this.setTileFromSource,
      required this.tileMode,
      required this.tiles,
      required this.preferredSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
          "${tiles.name} tile #${tiles.index} selected. ${tiles.count} tile(s) total"),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: setTileMode,
            child: Text(tileMode == true ? 'tile' : 'Map')),
        IntensityButton(
          intensity: 0,
          onPressed: setIntensity,
        ),
        IntensityButton(
          intensity: 1,
          onPressed: setIntensity,
        ),
        IntensityButton(
          intensity: 2,
          onPressed: setIntensity,
        ),
        IntensityButton(
          intensity: 3,
          onPressed: setIntensity,
        ),
        IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add tile',
            onPressed: addTile),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip:
              kIsWeb ? 'Save is not available for web' : 'Save source file',
          onPressed: kIsWeb ? null : () => saveFile(tiles.toSource()),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((nameValues) => nameValues != null
                ? setTileFromSource(nameValues[0], nameValues[1])
                : null)
          },
        )
      ],
    );
  }
}
