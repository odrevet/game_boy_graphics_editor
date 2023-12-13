import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import '../../models/sourceConverters/source_converter.dart';
import 'meta_tile_display.dart';

class MetaTileListView extends StatelessWidget {
  final Function onTap;
  final Function? onHover;
  final int selectedTile;

  const MetaTileListView({
    super.key,
    required this.onTap,
    this.onHover,
    required this.selectedTile,
  });

  @override
  Widget build(BuildContext context) {
    var metaTile = context.read<MetaTileCubit>().state;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: context.read<MetaTileCubit>().count(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: SizedBox(
            width: 40 * (metaTile.width / metaTile.height),
            height: 40,
            child: MetaTileDisplay(
              showGrid: false,
              tileData: metaTile.getTileAtIndex(index),
            ),
          ),
          title: Text(
              "#${index.toString()} ${decimalToHex(index, prefix: true)}",
              style: selectedTile == index
                  ? const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)
                  : null),
          onTap: () => onTap(index),
        );
      },
    );
  }
}
