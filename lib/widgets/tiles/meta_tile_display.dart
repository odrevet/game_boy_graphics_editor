import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/dot_matrix.dart';

class MetaTileDisplay extends StatelessWidget {
  final List<int> tileData;
  final bool showGrid;

  const MetaTileDisplay(
      {required this.tileData, this.showGrid = false, super.key});

  @override
  Widget build(BuildContext context) => DotMatrix(
      pixels: tileData
          .map((e) => Color(context.read<AppStateCubit>().state.colorSet[e]))
          .toList(),
      showGrid: showGrid,
      width: context.read<MetaTileCubit>().state.width,
      height: context.read<MetaTileCubit>().state.height);
}
