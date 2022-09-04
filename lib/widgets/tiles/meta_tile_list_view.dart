import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import '../../cubits/app_state_cubit.dart';
import 'meta_tile_display.dart';

class MetaTileListView extends StatelessWidget {
  final Function onTap;
  final Function? onHover;

  const MetaTileListView({
    Key? key,
    required this.onTap,
    this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
          width: 180,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: context.read<MetaTileCubit>().state.tileData.length ~/
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
                        style: context.read<AppStateCubit>().state.tileIndexTile == index
                            ? const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                            : null,
                      ),
                      title: MetaTileDisplay(
                          tileData: context.read<MetaTileCubit>().state.getTile(index),
                          showGrid: false,
                          metaTileIndex: index,
                          colorSet: context.read<AppStateCubit>().state.colorSet),
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
