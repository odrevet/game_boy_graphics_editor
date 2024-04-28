import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_bar.dart';

Future<void> _initPreferences(BuildContext context) async {
  SharedPreferences.getInstance().then((prefs) {
    String? storedString = prefs.getString('gbdkPath');
    if (storedString != null) {
      context.read<AppStateCubit>().setGbdkPath(storedString);
      context.read<AppStateCubit>().setGbdkPathValid();
    }
  });
}

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPreferences(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
          child: Column(
            children: [ApplicationMenuBar(), Expanded(child: TilesEditor())],
          ),
        ));
  }
}
