import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/app_state_cubit.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Palette"),
            TextButton(
                onPressed: () => context.read<AppStateCubit>().toggleColorSet(),
                child: const Text("DMG / Pocket")),
            const Text("Display"),
            TextButton(
                onPressed: () => context
                    .read<AppStateCubit>()
                    .toggleDisplayExportPreviewTile(),
                child: const Text("Display Tile Export source preview")),
            TextButton(
                onPressed: () => context
                    .read<AppStateCubit>()
                    .toggleDisplayExportPreviewBackground(),
                child: const Text("Display Background source preview")),
            TextFormField(
                decoration: const InputDecoration(labelText: 'GBDK Path'),
                key: Key(context.read<AppStateCubit>().state.tileName),
                initialValue: context.read<AppStateCubit>().state.gbdkPath,
                onChanged: (text) =>
                    context.read<AppStateCubit>().setGbdkPath(text)),
          ],
        ),
      ),
    );
  }
}
