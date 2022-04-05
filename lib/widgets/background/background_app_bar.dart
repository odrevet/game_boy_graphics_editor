import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../background.dart';
import '../../download_stub.dart' if (dart.library.html) '../../download.dart';
import '../../file_utils.dart';

class BackgroundAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final VoidCallback toggleGridBackground;
  final bool showGrid;
  final Function setBackgroundFromSource;
  final Background background;
  final int selectedTileIndex;
  final Function saveGraphics;
  final VoidCallback setTileMode;

  const BackgroundAppBar({
    this.preferredSize = const Size.fromHeight(50.0),
    Key? key,
    required this.toggleGridBackground,
    required this.showGrid,
    required this.setBackgroundFromSource,
    required this.background,
    required this.selectedTileIndex,
    required this.setTileMode,
    required this.saveGraphics,
  }) : super(key: key);

  Widget _setTileModeButton() {
    return ElevatedButton.icon(
        onPressed: setTileMode,
        icon: const Icon(Icons.wallpaper),
        label: const Text('Background'));
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    actions = [
      IconButton(
        icon: Icon(showGrid == true ? Icons.grid_on : Icons.grid_off),
        tooltip: '${showGrid ? 'Hide' : 'Show'} grid',
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
              tooltip: 'Save background as',
              onPressed: () => saveGraphics(background, context),
            ),
      IconButton(
        icon: const Icon(Icons.folder_open),
        tooltip: 'Open source file',
        onPressed: () => {
          selectFile(['c']).then((result) {
            if (result == null) {
              var snackBar = const SnackBar(
                content: Text("Not loaded"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              var snackBar = const SnackBar(
                content: Text("Loading"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              readBytes(result)
                  .then((source) => setBackgroundFromSource(source));
            }
          })
        },
      ),
    ];

    return AppBar(
      title: _setTileModeButton(),
      actions: actions,
    );
  }
}
