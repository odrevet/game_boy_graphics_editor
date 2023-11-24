import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';

import '../../cubits/meta_tile_cubit.dart';
import '../../models/graphics/meta_tile.dart';
import '../tiles/meta_tile_display.dart';

class BackgroundGrid extends StatelessWidget {
  final Background background;
  final MetaTile metaTile;
  final Function? onTap;
  final Function? onHover;
  final bool showGrid;

  const BackgroundGrid({
    Key? key,
    required this.background,
    required this.metaTile,
    this.onTap,
    this.onHover,
    this.showGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: metaTile.width / metaTile.height,
          crossAxisCount: background.width,
        ),
        itemBuilder: _build,
        itemCount: background.width * background.height,
      ),
    );
  }

  Widget _build(BuildContext context, int index) {
    Widget tileWidget;
    
    if (background.data[index] >=
        (context.read<MetaTileCubit>().state.data.length ~/
            (context.read<MetaTileCubit>().state.height *
                context.read<MetaTileCubit>().state.width))) {
      tileWidget = Container(
        alignment: Alignment.center,
        child: const Text(
          "Overflow",
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      );
    } else {
      tileWidget = MetaTileDisplay(
        tileData: metaTile.getMetaTile(background.data[index] - context.read<BackgroundCubit>().state.origin),
      );
    }

    if (showGrid) {
      tileWidget = Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
        child: tileWidget,
      );
    }

    if (onTap != null) {
      return MouseRegion(
        onHover: (_) => onHover != null ? onHover!(index) : null,
        cursor: SystemMouseCursors.precise,
        child: GestureDetector(
          onTap: () => onTap!(index),
          child: tileWidget,
        ),
      );
    }
    {
      return tileWidget;
    }
  }
}
