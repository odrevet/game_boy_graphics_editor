import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/import_page.dart';
import 'package:game_boy_graphics_editor/widgets/export_page.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_settings.dart';

import 'background/background_settings.dart';

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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ImportPage(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_upward),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Import'),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExportPage(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_downward),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Export'),
                      ],
                    ),
                  ),
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),

              // View Menu
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      // Clear navigation stack and go to editor
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.read<AppStateCubit>().navigateToEditor();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Editor'),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      // Clear navigation stack and go to memory manager
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.read<AppStateCubit>().navigateToMemoryManager();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.storage),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Memory Manager'),
                      ],
                    ),
                  ),
                ],
                child: const MenuAcceleratorLabel('&View'),
              ),

              // Edit Menu
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertDialogContext) =>
                        const AlertDialog(
                          title: Text('Properties'),
                          content: Row(
                            children: [
                              TileSettings(),
                              BackgroundSettings(),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.tune),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Properties'),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      // Clear navigation stack and go to settings
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.read<AppStateCubit>().navigateToSettings();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 5),
                        MenuAcceleratorLabel('&Settings'),
                      ],
                    ),
                  ),
                ],
                child: const MenuAcceleratorLabel('&Edit'),
              ),

              // About Menu
              MenuItemButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GameBoy Graphics Editor',
                    applicationVersion: '2.1.0',
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