import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';

import '../../cubits/app_state_cubit.dart';

class BackgroundProperties extends StatefulWidget {
  const BackgroundProperties({super.key});

  @override
  State<BackgroundProperties> createState() => _BackgroundPropertiesState();
}

class _BackgroundPropertiesState extends State<BackgroundProperties> {
  final TextEditingController _controllerHeight = TextEditingController();

  final TextEditingController _controllerWidth = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerWidth.text = context.read<BackgroundCubit>().state.width.toString();
    _controllerHeight.text = context.read<BackgroundCubit>().state.height.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, Background>(
        builder: (context, background) {
      return Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            initialValue: context.read<AppStateCubit>().state.backgroundName,
            onChanged: (text) =>
                context.read<AppStateCubit>().setBackgroundName(text),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('^[0-9]*')),
                    ],
                    decoration: const InputDecoration(labelText: 'Width'),
                    key: Key(context.read<AppStateCubit>().state.tileName),
                    controller: _controllerWidth),
              ),
              ElevatedButton(
                  onPressed: () {
                    context
                        .read<BackgroundCubit>()
                        .setWidth(int.parse(_controllerWidth.text));
                  },
                  child: const Text('Set Width'))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('^[0-9]*')),
                    ],
                    decoration: const InputDecoration(labelText: 'Height'),
                    key: Key(context.read<AppStateCubit>().state.tileName),
                    controller: _controllerHeight),
              ),
              ElevatedButton(
                  onPressed: () {
                    context
                        .read<BackgroundCubit>()
                        .setHeight(int.parse(_controllerHeight.text));
                  },
                  child: const Text('Set Height'))
            ],
          ),
          TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('^[0-9]*')),
              ],
              decoration: const InputDecoration(labelText: 'Origin'),
              key: const Key('tileOrigin'),
              initialValue:
                  context.read<BackgroundCubit>().state.tileOrigin.toString(),
              onChanged: (text) =>
                  context.read<BackgroundCubit>().setOrigin(int.parse(text))),
        ],
      );
    });
  }
}
