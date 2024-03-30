import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/widgets/importDialog.dart';
import 'package:game_boy_graphics_editor/widgets/settings_dialog.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tile_settings.dart';

import '../cubits/app_state_cubit.dart';
import 'background/background_settings.dart';
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
                        builder: (BuildContext alertDialogContext) =>
                            const AlertDialog(
                          title: Text('Import'),
                          content: ImportDialog(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.upload),
                        // Replace 'someIcon' with the icon you want
                        SizedBox(width: 5),
                        // Adjust the spacing between icon and text as needed
                        MenuAcceleratorLabel('&Import'),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext alertDialogContext) =>
                            const AlertDialog(
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

              // Edit
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext alertDialogContext) =>
                              const AlertDialog(
                                  title: Text('Properties'),
                                  content: Row(children: [
                                    TileSettings(),
                                    BackgroundSettings()
                                  ])));
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
                    applicationVersion: '1.0.2',
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
