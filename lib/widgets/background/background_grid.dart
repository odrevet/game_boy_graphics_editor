import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/models/background.dart';
import 'package:game_boy_graphics_editor/widgets/tiles/meta_tile_display.dart';

import '../../models/meta_tile.dart';

class BackgroundGrid extends StatelessWidget {
  final Background background;
  final MetaTile metaTile;
  final Function? onTap;
  final Function? onHover;
  final bool showGrid;
  final List<Color> colorSet;

  const BackgroundGrid({
    Key? key,
    required this.background,
    required this.metaTile,
    required this.colorSet,
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

    if (background.data[index] >= metaTile.tileList.length) {
      tileWidget = Container(
        alignment: Alignment.center,
        child: const Text(
          'Error',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      );
    } else {
      tileWidget = Container(); /*MetaTileDisplay(
          colorSet: colorSet,
          metaTile: metaTile,
          showGrid: false,
          metaTileIndex: background.data[index]);*/
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

