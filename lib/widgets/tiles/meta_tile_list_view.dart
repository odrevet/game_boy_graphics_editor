import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import 'meta_tile_display.dart';

class MetaTileListView extends StatelessWidget {
  final Function onTap;
  final Function? onHover;
  final int selectedTile;

  const MetaTileListView({
    Key? key,
    required this.onTap,
    this.onHover,
    required this.selectedTile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
          width: 180,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: context.read<MetaTileCubit>().state.data.length ~/
                (context.read<MetaTileCubit>().state.height *
                    context.read<MetaTileCubit>().state.width),
            itemBuilder: (context, index) {
              return MouseRegion(
                onHover: (_) => onHover != null ? onHover!(index) : null,
                child: SizedBox(
                  height: 132,
                  child: Card(
                    child: ListTile(
                      onTap: () => onTap(index),
                      leading: Text(
                        "$index",
                        style: selectedTile == index
                            ? const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                            : null,
                      ),
                      title: SizedBox(
                        child: MetaTileDisplay(
                          tileData: context.read<MetaTileCubit>().state.getTile(index),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
