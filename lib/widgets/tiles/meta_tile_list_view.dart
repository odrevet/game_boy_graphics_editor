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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: context.read<MetaTileCubit>().state.data.length ~/
          (context.read<MetaTileCubit>().state.height *
              context.read<MetaTileCubit>().state.width),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onTap(index),
          child: MouseRegion(
            onHover: (_) => onHover != null ? onHover!(index) : null,
            child: Card(
              child: Column(
                children: [
                  Text(
                      "#${index.toString()} ${decimalToHex(index, prefix: true)}",
                      style: selectedTile == index
                          ? const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)
                          : null),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MetaTileDisplay(
                        showGrid: false,
                        tileData: context
                            .read<MetaTileCubit>()
                            .state
                            .getMetaTile(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
