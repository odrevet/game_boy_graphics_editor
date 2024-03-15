import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cubits/app_state_cubit.dart';
import '../models/app_state.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) => SizedBox(
        height: 400,
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Palette"),
              TextButton(
                  onPressed: () =>
                      context.read<AppStateCubit>().toggleColorSet(),
                  child: const Text("DMG / Pocket")),
              const Divider(),
              const Text('GBDK bin Path'),
              Text(appState.gbdkPathValid
                  ? 'OK'
                  : 'Set GBDK Path to enable RLE compressed files load'),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    decoration: const InputDecoration(labelText: 'GBDK Path'),
                    key: Key(appState.gbdkPath),
                    initialValue: appState.gbdkPath,
                    readOnly: true,
                  )),
                  ElevatedButton.icon(
                    onPressed: kIsWeb
                        ? null
                        : () {
                            FilePicker.platform
                                .getDirectoryPath()
                                .then((dir) async {
                              if (dir != null) {
                                context.read<AppStateCubit>().setGbdkPath(dir);
                                context
                                    .read<AppStateCubit>()
                                    .setGbdkPathValid();

                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('gbdkPath', dir);
                              }
                            });
                          },
                    icon: const Icon(Icons.folder),
                    label: const Text('Set'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
