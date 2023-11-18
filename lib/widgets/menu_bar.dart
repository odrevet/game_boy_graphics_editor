import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/meta_tile_cubit.dart';

//import '../models/download.dart';
import '../models/file_utils.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';
import '../models/sourceConverters/source_converter.dart';

class ApplicationMenuBar extends StatelessWidget {
  const ApplicationMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: MenuBar(
            children: <Widget>[
              MenuItemButton(
                  onPressed: () =>
                      context.read<AppStateCubit>().toggleTileMode(),
                  child: const Icon(Icons.wallpaper)),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      if (kIsWeb) {
                        /*download(
                            GBDKTileConverter().toHeader(context.read<MetaTileCubit>().state,
                                context.read<AppStateCubit>().state.tileName),
                            '${context.read<AppStateCubit>().state.tileName}.h');
                        download(
                            GBDKTileConverter().toSource(context.read<MetaTileCubit>().state,
                                context.read<AppStateCubit>().state.tileName),
                            '${context.read<AppStateCubit>().state.tileName}.c');*/
                      } else {
                        //saveGraphics();
                      }
                    },
                    child: const MenuAcceleratorLabel('&Save'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      selectFile(['c', 'png']).then((result) {
                        late SnackBar snackBar;
                        if (result == null) {
                          snackBar = const SnackBar(
                            content: Text("Not loaded"),
                          );
                        } else {
                          final bool hasLoaded =
                              false; // loadTileFromFilePicker(result);
                          snackBar = SnackBar(
                            content: Text(
                                hasLoaded ? "Data loaded" : "Data not loaded"),
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    child: const MenuAcceleratorLabel('&Open'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),

              // View
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () =>
                        context.read<AppStateCubit>().toggleGridTile(),
                    child: const MenuAcceleratorLabel('Toggle &grid'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&View'),
              ),

              // Edit
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext alertDialogContext) =>
                              AlertDialog(
                                title: const Text('Settings'),
                                content: SizedBox(
                                  height: 400,
                                  width: 500,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Text("Properties"),
                                        TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('^[a-zA-Z0-9_]*')),
                                            ],
                                            decoration: const InputDecoration(
                                                labelText: 'Name'),
                                            key: Key(context
                                                .read<AppStateCubit>()
                                                .state
                                                .tileName),
                                            initialValue: context
                                                .read<AppStateCubit>()
                                                .state
                                                .tileName,
                                            onChanged: (text) => context
                                                .read<AppStateCubit>()
                                                .setTileName(text)),
                                        /*TextFormField(
                                            maxLines: null,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('^[a-zA-Z0-9_]*')),
                                            ],
                                            decoration: const InputDecoration(
                                                labelText: 'Values'),
                                            key: const Key('values'),
                                            initialValue: GBDKTileConverter()
                                                .toBin(context
                                                    .read<MetaTileCubit>()
                                                    .state),
                                            onChanged: (text) => context
                                                .read<MetaTileCubit>()
                                                .setData(hexToIntList(text))),*/
                                        const Text("Display"),
                                        TextButton(
                                            onPressed: () => context
                                                .read<AppStateCubit>()
                                                .toggleColorSet(),
                                            child: const Text("DMG / Pocket")),
                                        TextButton(
                                            onPressed: () => context
                                                .read<AppStateCubit>()
                                                .toggleDisplayExportPreviewTile(),
                                            child: const Text(
                                                "Display Export Preview"))
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                    },
                    child: const MenuAcceleratorLabel('Settings'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&Edit'),
              ),

              MenuItemButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GameBoy Graphics Editor',
                    applicationVersion: '1.0.1',
                  );
                },
                child: const MenuAcceleratorLabel('&About'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
