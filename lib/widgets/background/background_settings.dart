import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';

import 'background_properties.dart';

class BackgroundSettings extends StatelessWidget {
  const BackgroundSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const BackgroundProperties(),
            ElevatedButton(
                onPressed: () {
                  context.read<BackgroundCubit>().transpose();
                },
                child: const Text("Transpose rows and columns"))
          ],
        ),
      ),
    );
  }
}
