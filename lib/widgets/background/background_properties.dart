import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';

import '../../cubits/app_state_cubit.dart';

class BackgroundProperties extends StatelessWidget {
  const BackgroundProperties({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, Background>(builder: (context, background) {
      return Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            initialValue: context.read<AppStateCubit>().state.backgroundName,
            onChanged: (text) => context.read<AppStateCubit>().setBackgroundName(text),
          ),
          Row(
            children: [
              Text("Width ${background.width}"),
              IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Column',
                  onPressed: () => context.read<BackgroundCubit>().insertCol(0, 0)),
              IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remove Column',
                  onPressed: () =>
                      background.width > 1 ? context.read<BackgroundCubit>().deleteCol(0) : null),
            ],
          ),
          Row(
            children: [
              Text("Height ${background.height}"),
              IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Row',
                  onPressed: () => context.read<BackgroundCubit>().insertRow(0, 0)),
              IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remove Row',
                  onPressed: () =>
                      background.height > 1 ? context.read<BackgroundCubit>().deleteRow(0) : null),
            ],
          ),
        ],
      );
    });
  }
}
