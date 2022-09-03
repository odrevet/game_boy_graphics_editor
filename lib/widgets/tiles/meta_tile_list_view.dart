import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_state_cubit.dart';
import 'meta_tile_display.dart';

class MetaTileListView extends StatefulWidget {
  final int selectedTile;
  final Function onTap;
  final Function? onHover;

  const MetaTileListView({
    Key? key,
    required this.selectedTile,
    required this.onTap,
    this.onHover,
  }) : super(key: key);

  @override
  State<MetaTileListView> createState() => _MetaTileListViewState();
}

class _MetaTileListViewState extends State<MetaTileListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 180,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: context.read<AppStateCubit>().state.tileData.length ~/
              (context.read<AppStateCubit>().state.tileHeight *
                  context.read<AppStateCubit>().state.tileWidth),
          itemBuilder: (context, index) {
            return MouseRegion(
              onHover: (_) => widget.onHover != null ? widget.onHover!(index) : null,
              child: ListTile(
                onTap: () => widget.onTap(index),
                leading: Text(
                  "$index",
                  style: widget.selectedTile == index
                      ? const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                      : null,
                ),
                title: MetaTileDisplay(
                    tileData: context.read<AppStateCubit>().state.tileData,
                    showGrid: false,
                    metaTileIndex: index,
                    colorSet: context.read<AppStateCubit>().state.colorSet),
              ),
            );
          },
        ));
  }
}
