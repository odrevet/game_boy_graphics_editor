import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

class MapWidget extends StatefulWidget {
  final int mapHeight;
  final int mapWidth;
  final List<int> mapData;
  final List<int> tileData;
  final int tileSize;
  final Function? onTap;

  const MapWidget(
      {Key? key,
      required this.mapHeight,
      required this.mapWidth,
      required this.mapData,
      required this.tileData,
      required this.tileSize,
      required this.onTap})
      : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.mapWidth,
        ),
        itemBuilder: _build,
        itemCount: widget.mapWidth * widget.mapHeight,
      ),
    );
  }

  Widget _build(BuildContext context, int index) {
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () => widget.onTap!(index),
        child: TileWidget(
            intensity: widget.tileData.sublist(
                (widget.tileSize * widget.tileSize) * widget.mapData[index],
                (widget.tileSize * widget.tileSize) *
                    (widget.mapData[index] + 1))),
      );
    }
    {
      return TileWidget(
          intensity: widget.tileData.sublist(
              (widget.tileSize * widget.tileSize) * widget.mapData[index],
              (widget.tileSize * widget.tileSize) *
                  (widget.mapData[index] + 1)));
    }
  }
}
