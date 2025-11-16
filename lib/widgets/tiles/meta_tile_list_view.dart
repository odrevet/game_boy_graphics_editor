import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/cubits/meta_tile_cubit.dart';

import '../../core/converter_utils.dart';
import '../../cubits/graphics_cubit.dart';
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
    MetaTile? tileInfo,
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

  void _showTileInfo(BuildContext context, int index, MetaTile? tileInfo) {
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
            if (tileInfo != null && tileInfo.name.isNotEmpty)
              Text("Source: ${tileInfo.name}"),
            if (tileInfo != null) Text("Source Origin: ${tileInfo.tileOrigin}"),
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
              // Get the MetaTileCubit and meta tiles info
              final metaTileCubit = context.read<MetaTileCubit>();
              final currentMetaTile = metaTileCubit.state;
              final metaTilesInfo = metaTileCubit.getMetaTilesInfo();

              // Calculate tile size
              final tileSize = currentMetaTile.height * currentMetaTile.width;

              // Collect ONLY unmapped tile data
              List<int> unmappedData = [];
              for (int index = 0; index < metaTilesInfo.length; index++) {
                final tileInfo = metaTilesInfo[index];

                // Check if this tile is unmapped
                bool isUnmappedTile = tileInfo == null || tileInfo.name.isEmpty;

                if (isUnmappedTile) {
                  // Extract this tile's data
                  final startIndex = index * tileSize;
                  final endIndex = startIndex + tileSize;

                  if (endIndex <= currentMetaTile.data.length) {
                    unmappedData.addAll(
                      currentMetaTile.data.sublist(startIndex, endIndex),
                    );
                  }
                }
              }

              // Only commit if there are unmapped tiles
              if (unmappedData.isNotEmpty) {
                var unmappedMetaTile = MetaTile(
                  height: currentMetaTile.height,
                  width: currentMetaTile.width,
                  data: unmappedData,
                  name: "Unmapped",
                );

                // Commit unmapped tiles to graphics
                context.read<GraphicsCubit>().commitMetaTileToGraphics(
                  unmappedMetaTile,
                  "Unmapped Graphics",
                  0, // Default origin for unmapped tiles
                );

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unmapped tiles saved to graphics'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // Show message if no unmapped tiles found
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No unmapped tiles to save'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.arrow_circle_right),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListItems(
    BuildContext context,
    List<MetaTile?> metaTilesInfo,
    int tileOrigin,
    var metaTile,
  ) {
    List<Widget> items = [];
    String? currentSource;
    int? currentOrigin;
    bool hasAddedUnmappedHeader = false;

    for (int index = 0; index < metaTilesInfo.length; index++) {
      MetaTile? tileInfo = metaTilesInfo[index];

      // Check if this is an unmapped tile (null or no source name)
      bool isUnmappedTile = tileInfo == null || tileInfo.name.isEmpty;

      if (isUnmappedTile) {
        // Add unmapped header only once
        if (!hasAddedUnmappedHeader) {
          items.add(_buildUnmappedHeader(context, metaTile));
          hasAddedUnmappedHeader = true;
          currentSource = null;
          currentOrigin = null;
        }
      } else {
        // Add separator when source changes (for mapped tiles)
        if (tileInfo.name != currentSource ||
            tileInfo.tileOrigin != currentOrigin) {
          items.add(
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    tileInfo.name,
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
                            tileInfo.name,
                            tileInfo.tileOrigin,
                          );

                      var sourceMetaTile = MetaTile(
                        height: 8,
                        width: 8,
                        data: sourceTileData,
                        name: tileInfo.name,
                        sourceInfo: tileInfo.sourceInfo,
                      );

                      // Commit with the extracted source-specific data
                      context.read<GraphicsCubit>().commitMetaTileToGraphics(
                        sourceMetaTile,
                        tileInfo.name,
                        tileInfo.tileOrigin,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${sourceMetaTile.name} tiles saved to graphics',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_circle_right),
                  ),
                ],
              ),
            ),
          );
          currentSource = tileInfo.name;
          currentOrigin = tileInfo.tileOrigin;
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
    var metaTilesInfo = context.read<MetaTileCubit>().getMetaTilesInfo();

    return ListView(
      shrinkWrap: true,
      children: _buildListItems(context, metaTilesInfo, tileOrigin, metaTile),
    );
  }
}
