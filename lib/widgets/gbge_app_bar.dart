import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/tiles.dart';

import '../background.dart';
import '../download_stub.dart' if (dart.library.html) '../download.dart';
import '../file_utils.dart';
import 'intensity_button.dart';

class GBGEAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final VoidCallback leftShift;
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
  final Function setTilesDimensions;
  final bool tileMode;
  final Tiles tiles;
  final Background background;
  final int selectedTileIndexTile;
  final int selectedTileIndexBackground;

  const GBGEAppBar(
      {Key? key,
      required this.leftShift,
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
      required this.setTilesDimensions,
      required this.tileMode,
      required this.tiles,
      required this.background,
      required this.selectedTileIndexTile,
      required this.selectedTileIndexBackground,
      this.preferredSize = const Size.fromHeight(50.0)})
      : super(key: key);

  Widget _tileDimensionsDropDown() {
    return DropdownButton<String>(
      value: "${tiles.width} x ${tiles.height}",
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

    if (tileMode) {
      actions = [
        /*IconButton(
            onPressed: leftShift,
            icon: const Icon(Icons.keyboard_arrow_left_rounded)),*/
        const VerticalDivider(),
        _tileDimensionsDropDown(),
        IconButton(
          icon: Icon(showGridTile == true ? Icons.grid_on : Icons.grid_off),
          tooltip: 'Show/Hide grid',
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
            onPressed: addTile),
        IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Remove tile',
            onPressed: removeTile),
        const VerticalDivider(),
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
                onPressed: () {
                  saveToDirectory(tiles).then((selectedDirectory) {
                    if (selectedDirectory != null) {
                      var snackBar = SnackBar(
                        content: Text(
                            "${tiles.name}.h and ${tiles.name}.c saved under $selectedDirectory"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                },
              ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: () => {
            selectFolder().then((source) {
              late SnackBar snackBar;
              if (source == null) {
                snackBar = const SnackBar(
                  content: Text("Not loaded"),
                );
              } else {
                snackBar = const SnackBar(
                  content: Text("Loaded"),
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            })
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
        const VerticalDivider(),
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
