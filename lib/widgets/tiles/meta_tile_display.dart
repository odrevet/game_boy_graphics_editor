import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/dot_matrix.dart';

import '../../colors.dart';
import '../../meta_tile.dart';
import '../../tile.dart';

class MetaTileDisplay extends StatelessWidget {
  final MetaTile metaTile;
  final Function? onTap;
  final bool showGrid;
  final int metaTileIndex;

  late final List<int> pattern;

  MetaTileDisplay(
      {required this.metaTile,
      required this.showGrid,
      required this.metaTileIndex,
      this.onTap,
      Key? key})
      : super(key: key) {
    if (metaTile.width == 8 && metaTile.height == 8) {
      pattern = <int>[0];
    } else if (metaTile.width == 8 && metaTile.height == 16) {
      pattern = <int>[0, 1];
    } else if (metaTile.width == 16 && metaTile.height == 16) {
      pattern = <int>[0, 2, 1, 3];
    } else if (metaTile.width == 32 && metaTile.height == 32) {
      pattern = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      pattern = <int>[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: metaTile.width ~/ Tile.size,
      children: <Widget>[
        for (int i = 0; i < metaTile.count(); i++)
          DotMatrix(
            onTap: onTap,
            onTapParam: metaTileIndex * metaTile.count() + pattern[i],
            pixels: metaTile
                .tileList[metaTileIndex * metaTile.count() + pattern[i]].data
                .map((e) => colors[e])
                .toList(),
            showGrid: showGrid,
            width: Tile.size,
            height: Tile.size,
          )
      ],
    );
  }
}
