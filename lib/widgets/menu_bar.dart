import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_state_cubit.dart';

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
                  onPressed: () => context.read<AppStateCubit>().toggleTileMode(),
                  child: const Icon(Icons.wallpaper)),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MenuBar Sample',
                        applicationVersion: '1.0.0',
                      );
                    },
                    child: const MenuAcceleratorLabel('&About'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved!'),
                        ),
                      );
                    },
                    child: const MenuAcceleratorLabel('&Save'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quit!'),
                        ),
                      );
                    },
                    child: const MenuAcceleratorLabel('&Quit'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&File'),
              ),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Magnify!'),
                        ),
                      );
                    },
                    child: const MenuAcceleratorLabel('&Magnify'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Minify!'),
                        ),
                      );
                    },
                    child: const MenuAcceleratorLabel('Mi&nify'),
                  ),
                ],
                child: const MenuAcceleratorLabel('&View'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
