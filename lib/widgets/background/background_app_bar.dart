import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';

import '../../models/graphics/background.dart';
import '../../models/file_utils.dart';

class BackgroundAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final Function setBackgroundFromSource;
  final Background background;
  final Function saveGraphics;

  const BackgroundAppBar({
    this.preferredSize = const Size.fromHeight(50.0),
    Key? key,
    required this.setBackgroundFromSource,
    required this.background,
    required this.saveGraphics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];

    actions = [
      IconButton(
        icon: Icon(context.read<AppStateCubit>().state.showGridBackground == true
            ? Icons.grid_on
            : Icons.grid_off),
        tooltip: '${context.read<AppStateCubit>().state.showGridBackground ? 'Hide' : 'Show'} grid',
        onPressed: () => context.read<AppStateCubit>().toggleGridBackground(),
      ),
      const VerticalDivider(),
      kIsWeb
          ? IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download',
              onPressed: () {
                //download(background.toHeader(), '${background.name}.h');
                //download(background.toSource(), '${background.name}.c');
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
              readBytes(result).then((source) => setBackgroundFromSource(source));
            }
          })
        },
      ),
    ];

    return AppBar(
      title: ElevatedButton.icon(
          onPressed: () => context.read<AppStateCubit>().toggleTileMode(),
          icon: const Icon(Icons.wallpaper),
          label: const Text('Background')),
      actions: actions,
    );
  }
}
