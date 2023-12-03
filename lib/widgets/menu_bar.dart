import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/settings_dialog.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_settings.dart';
import '../cubits/app_state_cubit.dart';
import 'background/background_settings.dart';
import '../models/menu_bar_callbacks.dart';

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
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () => onFileOpen(context),
                    child: const MenuAcceleratorLabel('&Open'),
                  ),
                  MenuItemButton(
                    onPressed: () => onFileOpenBin(context),
                    child: const MenuAcceleratorLabel('&Open bin'),
                  ),
                  MenuItemButton(
                    onPressed: () => onFileSaveAsSourceCode(context),
                    child: const MenuAcceleratorLabel('Save as &source code'),
                  ),
                  /*MenuItemButton(
                    onPressed: () {
                      saveFileBin(utf8.encode(GBDKTileConverter()
                          .toBin(context.read<MetaTileCubit>().state)), ['.bin'], 'data');
                    },
                    child: const MenuAcceleratorLabel('Save as &bin'),
                  ),*/
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),

              // View
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () => context
                            .read<AppStateCubit>()
                            .state
                            .tileMode
                        ? context.read<AppStateCubit>().toggleGridTile()
                        : context.read<AppStateCubit>().toggleGridBackground(),
                    child: const MenuAcceleratorLabel('Toggle &grid'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&View'),
              ),

              // Mode
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () =>
                        context.read<AppStateCubit>().setMode(true),
                    child: const MenuAcceleratorLabel('Tile'),
                  ),
                  MenuItemButton(
                    onPressed: () =>
                        context.read<AppStateCubit>().setMode(false),
                    child: const MenuAcceleratorLabel('Background'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&Mode'),
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
                                title: const Text('Properties'),
                                content:
                                context.read<AppStateCubit>().state.tileMode
                                    ? const TileSettings()
                                    : const BackgroundSettings(),
                              ));
                    },
                    child: const MenuAcceleratorLabel('Properties'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext alertDialogContext) =>
                              const AlertDialog(content: SettingsDialog()));
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
