import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/app_state_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';

import '../../models/sourceConverters/gbdk_tile_converter.dart';

class TileDimensionDropdown extends StatelessWidget {
  const TileDimensionDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetaTileCubit, MetaTile>(builder: (context, metaTile) {
      return DropdownButton<String>(
        value: "${metaTile.width} x ${metaTile.height}",
        onChanged: (String? value) {
          int width = 8;
          int height = 8;
          switch (value) {
            case '8 x 8':
              width = 8;
              height = 8;
              break;
            case '8 x 16':
              width = 8;
              height = 16;
              break;
            case '16 x 16':
              width = 16;
              height = 16;
              break;
            case '32 x 32':
              width = 32;
              height = 32;
              break;
          }

          var flattenedData =
              GBDKTileConverter().reorderFromCanvasToSource(context.read<MetaTileCubit>().state);
          var data = GBDKTileConverter().reorderFromSourceToCanvas(flattenedData, width, height);
          context.read<MetaTileCubit>().setData(data);
          context.read<MetaTileCubit>().setDimensions(width, height);
          context.read<AppStateCubit>().setSelectedTileIndex(0);
        },
        items: <String>['8 x 8', '8 x 16', '16 x 16', '32 x 32']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    });
  }
}
