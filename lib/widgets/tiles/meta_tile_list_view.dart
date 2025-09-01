import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import '../../cubits/graphics_cubit.dart';
import '../../models/converter_utils.dart';
import '../../models/graphics/meta_tile.dart';
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

  Widget _buildTileListItem(
    BuildContext context,
    int index,
    TileInfo tileInfo,
    int tileOrigin,
    var metaTile,
  ) {
    String title = "${index.toString()} ${decimalToHex(index, prefix: true)}";
    if (tileOrigin > 0) {
      title +=
          "\n${(index + tileOrigin).toString()} ${decimalToHex(index + tileOrigin, prefix: true)}";
    }

    return ListTile(
      leading: SizedBox(
        width: 40, // * (metaTile.width / metaTile.height),
        height: 40,
        child: MetaTileDisplay(
          showGrid: false,
          tileData: metaTile.getTileAtIndex(index),
        ),
      ),
      title: Text(
        title,
        style: selectedTile == index
            ? const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
            : null,
      ),
      onTap: () => onTap(index),
      onLongPress: () => _showTileInfo(context, index, tileInfo),
    );
  }

  void _showTileInfo(BuildContext context, int index, TileInfo tileInfo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Tile $index Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Index: $index"),
            Text("Hex: ${decimalToHex(index, prefix: true)}"),
            if (tileInfo.sourceName != null)
              Text("Source: ${tileInfo.sourceName}"),
            if (tileInfo.sourceIndex != null)
              Text("Source Index: ${tileInfo.sourceIndex}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MetaTileCubit>().removeTileAt(index);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListItems(
    BuildContext context,
    List<TileInfo> tileInfoList,
    int tileOrigin,
    var metaTile,
  ) {
    List<Widget> items = [];
    String? currentSource;
    int? currentOrigin;

    for (int index = 0; index < tileInfoList.length; index++) {
      TileInfo tileInfo = tileInfoList[index];

      // Add separator when source changes
      if (tileInfo.sourceName != currentSource ||
          tileInfo.origin != currentOrigin) {
        if (tileInfo.sourceName != null && tileInfo.sourceName!.isNotEmpty) {
          items.add(
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    tileInfo.sourceName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Expanded(child: Divider(indent: 8)),
                  IconButton(
                    onPressed: () {
                      // Use the MetaTileCubit to extract the correct source data
                      final metaTileCubit = context.read<MetaTileCubit>();
                      final sourceTileData = metaTileCubit
                          .extractSourceTileData(
                            tileInfo.sourceName!,
                            tileInfo.origin,
                          );

                      //var data = metaTile.data;
                      //var data = metaTileCubit.state.data;
                      //var metaTile = metaTileCubit.state;

                      var metaTile = MetaTile(
                        height: 8, // metaTile.height,
                        width: 8,// metaTile.width,
                        data: sourceTileData, //metaTileCubit.state.data,
                        //tileOrigin: tileInfo.origin,
                        name: tileInfo.sourceName,
                        );

                      // Commit with the extracted source-specific data
                      context.read<GraphicsCubit>().commitMetaTileToGraphics(
                        metaTile,
                        tileInfo.sourceName!,
                        tileInfo.origin,
                      );
                    },
                    icon: Icon(Icons.arrow_circle_right),
                  ),
                ],
              ),
            ),
          );
        }
        currentSource = tileInfo.sourceName;
        currentOrigin = tileInfo.origin;
      }

      // Add the tile item
      items.add(
        _buildTileListItem(context, index, tileInfo, tileOrigin, metaTile),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    int tileOrigin = context.read<BackgroundCubit>().state.tileOrigin;
    var metaTile = context.read<MetaTileCubit>().state;
    var tileInfoList = context.read<MetaTileCubit>().getTileInfoList();

    return ListView(
      shrinkWrap: true,
      children: _buildListItems(context, tileInfoList, tileOrigin, metaTile),
    );
  }
}
