import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cubits/app_state_cubit.dart';
import '../../models/colors.dart';
import '../models/states/app_state.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, appState) {
        final activeColors = appState.colorSet;
        final paletteName = identical(activeColors, colorsPocket)
            ? "Pocket"
            : "DMG";

        return SizedBox(
          height: 400,
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Palette Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Palette",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("Selected: $paletteName"),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () =>
                                  context
                                      .read<AppStateCubit>()
                                      .toggleColorSet(),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text("Switch"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: activeColors
                              .map(
                                (c) =>
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(c),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black26),
                                  ),
                                ),
                          )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // GBDK Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GBDK bin Path",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appState.gbdkPathValid
                              ? '✓ Valid path'
                              : '⚠ Set GBDK Path to enable RLE compressed files load',
                          style: TextStyle(
                            color: appState.gbdkPathValid
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'GBDK Path',
                                  border: OutlineInputBorder(),
                                ),
                                key: Key(appState.gbdkPath),
                                initialValue: appState.gbdkPath,
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: kIsWeb
                                  ? null
                                  : () {
                                FilePicker.platform.getDirectoryPath().then((
                                    dir,) async {
                                  if (dir != null) {
                                    context
                                        .read<AppStateCubit>()
                                        .setGbdkPath(dir);
                                    context
                                        .read<AppStateCubit>()
                                        .setGbdkPathValid();

                                    final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'gbdkPath',
                                      dir,
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Browse'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
