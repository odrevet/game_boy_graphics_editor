import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';
import '../../cubits/meta_tile_cubit.dart';

import '../../models/sourceConverters/gbdk_tile_converter.dart';
import '../../models/sourceConverters/source_converter.dart';

class TileSettings extends StatelessWidget {
  const TileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Properties"),
            TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('^[a-zA-Z0-9_]*')),
                ],
                decoration: const InputDecoration(labelText: 'Name'),
                key: Key(context.read<AppStateCubit>().state.tileName),
                initialValue: context.read<AppStateCubit>().state.tileName,
                onChanged: (text) =>
                    context.read<AppStateCubit>().setTileName(text)),
            TextFormField(
                maxLines: null,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('^[a-fA-F0-9_]*')),
                ],
                decoration: const InputDecoration(labelText: 'Values'),
                key: const Key('values'),
                initialValue: GBDKTileConverter()
                    .toBin(context.read<MetaTileCubit>().state),
                onChanged: (text) {
                  var data = GBDKTileConverter()
                      .fromSource(formatHexPairs(text).split(','));
                  data = GBDKTileConverter().reorderFromSourceToCanvas(
                      data,
                      context.read<MetaTileCubit>().state.width,
                      context.read<MetaTileCubit>().state.height);
                  context.read<MetaTileCubit>().setData(data);
                }),
            const Text("Display"),
            TextButton(
                onPressed: () => context.read<AppStateCubit>().toggleColorSet(),
                child: const Text("DMG / Pocket")),
            TextButton(
                onPressed: () => context
                    .read<AppStateCubit>()
                    .toggleDisplayExportPreviewTile(),
                child: const Text("Display Export Preview"))
          ],
        ),
      ),
    );
  }
}
