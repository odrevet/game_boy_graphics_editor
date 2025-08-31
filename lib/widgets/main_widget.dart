import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/graphic_list_widget.dart';
import 'package:game_boy_graphics_editor/widgets/settings_widget.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/tiles_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/states/app_state.dart';
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

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPreferences(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ApplicationMenuBar(),
            Expanded(
              child: BlocBuilder<AppStateCubit, AppState>(
                builder: (context, state) {
                  switch (state.currentView) {
                    case ViewType.editor:
                      return const TilesEditor();
                    case ViewType.memoryManager:
                      return const GraphicsListWidget();
                    case ViewType.settings:
                      return const SettingsWidget();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
