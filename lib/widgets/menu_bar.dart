import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/importDialog.dart';
import 'package:game_boy_graphics_editor/widgets/settings_dialog.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_toolbar.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_settings.dart';

import '../cubits/app_state_cubit.dart';
import 'background/background_settings.dart';
import 'background/background_toolbar.dart';
import 'exportDialog.dart';

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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertDialogContext) => const AlertDialog(
                          title: Text('Import'),
                          content: ImportDialog(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.upload), // Replace 'someIcon' with the icon you want
                        SizedBox(width: 5), // Adjust the spacing between icon and text as needed
                        MenuAcceleratorLabel('&Import'),
                      ],
                    ),
                  )
,
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertDialogContext) => const AlertDialog(
                          title: Text('Export'),
                          content: ExportDialog(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Export'),
                      ],
                    ),
                  )
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),

              // View
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () => context.read<AppStateCubit>().setMode(true),
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('Tile'),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () => context.read<AppStateCubit>().setMode(false),
                    child: const Row(
                      children: [
                        Icon(Icons.grid_4x4),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('Background'),
                      ],
                    ),
                  ),

                  const Divider(),
                  MenuItemButton(
                    onPressed: () => context
                            .read<AppStateCubit>()
                            .state
                            .tileMode
                        ? context.read<AppStateCubit>().toggleGridTile()
                        : context.read<AppStateCubit>().toggleGridBackground(),
                      child: const Row(
                        children: [
                          Icon(Icons.grid_on),
                          SizedBox(width: 5), 
                          MenuAcceleratorLabel('Toggle &grid'),
                        ],
                      )
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

              // ignore: prefer_const_constructors
              context.read<AppStateCubit>().state.tileMode
                  ? MetaTileToolbar()
                  : BackgroundToolbar(),
            ],
          ),
        ),
      ],
    );
  }
}
