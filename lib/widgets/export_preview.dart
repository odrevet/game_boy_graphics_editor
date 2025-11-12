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
  final Graphics graphics;

  const ExportPreview(this.graphics, this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    final graphic = graphics; // Create local variable for type promotion

    if (type == 'Source code') {
      var name = graphic.name;
      var header = '';
      var source = '';

      if (graphic is Background) {
        header = GBDKBackgroundConverter().toHeader(graphic, name);
        source = GBDKBackgroundConverter().toSource(graphic, name);
      } else if (graphic is MetaTile) {
        header = GBDKTileConverter().toHeader(graphic, name);
        source = GBDKTileConverter().toSource(graphic, name);
      } else {
        // For base Graphics type, default to tile conversion
        header = GBDKTileConverter().toHeader(graphic, name);
        source = GBDKTileConverter().toSource(graphic, name);
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
      if (graphic is MetaTile) {
        bytes = GBDKTileConverter().getRawTileInt(
          GBDKTileConverter().reorderFromCanvasToSource(graphic),
        );
      } else if (graphic is Background) {
        bytes = graphic.data;
      }

      return Text(bytes.toString());
    } else if (type == 'PNG') {
      var png;
      if (graphic is MetaTile) {
        List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
        int count = graphic.data.length ~/ (graphic.height * graphic.width);

        png = tilesToPNG(graphic, colorSet, count);
      } else if (graphic is Background) {
        MetaTile metaTile = context.read<MetaTileCubit>().state;
        List<int> colorSet = context.read<AppStateCubit>().state.colorSet;
        png = backgroundToPNG(graphic, metaTile, colorSet);
      } else {
        // For base Graphics type, we cannot generate PNG since tilesToPNG requires MetaTile
        // and backgroundToPNG requires Background
        png = null;
      }

      if (png != null) {
        return Image.memory(
          png,
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        );
      } else {
        return const Center(
          child: Text(
            "PNG preview not available for this graphics type",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
    }

    return const Center(
      child: Text(
        "No preview available",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
