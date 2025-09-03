import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import '../../cubits/graphics_cubit.dart';
import '../../models/sourceConverters/converter_utils.dart';
import '../../models/graphics/meta_tile.dart';
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

    // Calculate the correct aspect ratio based on MetaTile dimensions
    final double aspectRatio = metaTile.width / metaTile.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        leading: AspectRatio(
          aspectRatio: aspectRatio,
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
      ),
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

  Widget _buildUnmappedHeader(BuildContext context, var metaTile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Text(
            "Unmapped",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const Expanded(child: Divider(indent: 8)),
          IconButton(
            onPressed: () {
              // Create a MetaTile with all unmapped tiles
              final metaTileCubit = context.read<MetaTileCubit>();
              final currentMetaTile = metaTileCubit.state;

              var unmappedMetaTile = MetaTile(
                height: currentMetaTile.height,
                width: currentMetaTile.width,
                data: currentMetaTile.data,
                name: "Unmapped",
              );

              // Commit unmapped tiles to graphics
              context.read<GraphicsCubit>().commitMetaTileToGraphics(
                unmappedMetaTile,
                "Unmapped Graphics",
                0, // Default origin for unmapped tiles
              );
            },
            icon: const Icon(Icons.arrow_circle_right),
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
    bool hasAddedUnmappedHeader = false;

    for (int index = 0; index < tileInfoList.length; index++) {
      TileInfo tileInfo = tileInfoList[index];

      // Check if this is an unmapped tile (no source name or empty source name)
      bool isUnmappedTile =
          tileInfo.sourceName == null || tileInfo.sourceName!.isEmpty;

      if (isUnmappedTile) {
        // Add unmapped header only once and only if we haven't added it yet
        if (!hasAddedUnmappedHeader) {
          items.add(_buildUnmappedHeader(context, metaTile));
          hasAddedUnmappedHeader = true;
          currentSource = null; // Reset current source for unmapped section
          currentOrigin = null;
        }
      } else {
        // Add separator when source changes (for mapped tiles)
        if (tileInfo.sourceName != currentSource ||
            tileInfo.origin != currentOrigin) {
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

                      var sourceMetaTile = MetaTile(
                        height: 8, // metaTile.height,
                        width: 8, // metaTile.width,
                        data: sourceTileData,
                        name: tileInfo.sourceName,
                      );

                      // Commit with the extracted source-specific data
                      context.read<GraphicsCubit>().commitMetaTileToGraphics(
                        sourceMetaTile,
                        tileInfo.sourceName!,
                        tileInfo.origin,
                      );
                    },
                    icon: const Icon(Icons.arrow_circle_right),
                  ),
                ],
              ),
            ),
          );
          currentSource = tileInfo.sourceName;
          currentOrigin = tileInfo.origin;
        }
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
