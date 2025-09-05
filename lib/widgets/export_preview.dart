import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/gbdk_background_converter.dart';
import 'package:game_boy_graphics_editor/widgets/source_display.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import '../models/graphics/graphics.dart';
import '../models/graphics/meta_tile.dart';
import '../models/png.dart';
import '../models/sourceConverters/gbdk_tile_converter.dart';

class ExportPreview extends StatelessWidget {
  final String type;
  final String parse;
  final Graphics graphics;

  const ExportPreview(this.graphics, this.type, this.parse, {super.key});

  @override
  Widget build(BuildContext context) {
    if (type == 'Source code') {
      var name = graphics.name;
      var header = '';
      var source = '';

      if (parse == 'Tile') {
        header = GBDKTileConverter().toHeader(graphics, name);
        source = GBDKTileConverter().toSource(graphics, name);
      } else if (parse == 'Background') {
        header = GBDKBackgroundConverter().toHeader(graphics, name);
        source = GBDKBackgroundConverter().toSource(graphics, name);
      }

      return Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SourceDisplay(source: header, name: name, extension: '.h'),
                const SizedBox(height: 12),
                SourceDisplay(source: source, name: name, extension: '.c'),
              ],
            ),
          ),
        ],
      );
    } else if (type == 'Binary') {
      List<int> bytes = [];
      if (parse == 'Tile') {
        bytes = GBDKTileConverter().getRawTileInt(
          GBDKTileConverter().reorderFromCanvasToSource(graphics),
        );
      } else {
        // TODO
        //bytes = GBDKBackgroundConverter().getRawTileInt(
        //  GBDKBackgroundConverter().reorderFromCanvasToSource(graphics),
        //);
      }

      return Text(bytes.toString());
    } else if (type == 'PNG') {
      var png;
      if (parse == 'Tile') {
        List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
        int count = graphics.data.length ~/ (graphics.height * graphics.width);

        png = tilesToPNG(graphics as MetaTile, colorSet, count);
      } else {
        MetaTile metaTile = context.read<MetaTileCubit>().state;
        List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
        png = backgroundToPNG(graphics as Background, metaTile, colorSet);
      }

      return Image.memory(png, width: 300, height: 300, fit: BoxFit.contain);
    }

    return const Center(
      child: Text(
        "No preview available",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
