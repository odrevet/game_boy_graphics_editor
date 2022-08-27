import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Game Boy Graphic Editor',
        theme: ThemeData(
          fontFamily: 'RobotoMono',
          primarySwatch: Colors.grey,
        ),
        home: MultiBlocProvider(providers: [
          BlocProvider(create: (_) => AppStateCubit()),
          BlocProvider(create: (_) => MetaTileCubit())
        ], child: const Editor()));
  }
}
