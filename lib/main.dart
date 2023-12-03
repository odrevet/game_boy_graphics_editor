import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AppStateCubit()),
            BlocProvider(create: (_) => MetaTileCubit()),
            BlocProvider(create: (_) => BackgroundCubit())
          ],
          child: MaterialApp(
              title: 'Game Boy Graphic Editor',
              theme: ThemeData(
                  fontFamily: 'RobotoMono',
                  primarySwatch: Colors.grey,
                  colorScheme: ColorScheme.fromSeed(
                    brightness: MediaQuery.platformBrightnessOf(context),
                    seedColor: Colors.grey,
                  ),
                  scrollbarTheme: const ScrollbarThemeData().copyWith(
                    thumbColor: MaterialStateProperty.all(Colors.blue[500]),
                    thickness: MaterialStateProperty.all(4.0),
                  )),
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: PointerDeviceKind.values.toSet(),
              ),
              home: const Editor()));
}
