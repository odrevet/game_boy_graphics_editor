import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/tiles/meta_tile_display.dart';

import '../../meta_tile.dart';

class MetaTileListView extends StatefulWidget {
  final MetaTile metaTiles;
  final int selectedTile;
  final Function onTap;
  final Function? onHover;

  const MetaTileListView({
    Key? key,
    required this.metaTiles,
    required this.selectedTile,
    required this.onTap,
    this.onHover,
  }) : super(key: key);

  @override
  _MetaTileListViewState createState() => _MetaTileListViewState();
}

class _MetaTileListViewState extends State<MetaTileListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 180,
        child: ListView.builder(
          itemCount: widget.metaTiles.tileList.length,
          itemBuilder: (context, index) {
            return MouseRegion(
              onHover: (_) =>
                  widget.onHover != null ? widget.onHover!(index) : null,
              child: ListTile(
                onTap: () => widget.onTap(index),
                leading: Text(
                  "$index",
                  style: widget.selectedTile == index
                      ? const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)
                      : null,
                ),
                title: MetaTileDisplay(
                    metaTile: widget.metaTiles,
                    showGrid: false,
                    metaTileIndex: index),
              ),
            );
          },
        ));
  }
}
