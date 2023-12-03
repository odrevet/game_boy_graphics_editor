import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/app_state_cubit.dart';
import 'background_properties.dart';

class BackgroundSettings extends StatelessWidget {
  const BackgroundSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            BackgroundProperties(),
          ],
        ),
      ),
    );
  }
}
