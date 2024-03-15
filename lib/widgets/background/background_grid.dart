import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/cubits/background_cubit.dart';
import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../cubits/meta_tile_cubit.dart';
import '../../models/graphics/meta_tile.dart';
import '../tiles/meta_tile_display.dart';

class BackgroundGrid extends StatefulWidget {
  final Background background;
  final MetaTile metaTile;
  final Function? onTap;
  final Function? onHover;
  final bool showGrid;
  final double cellSize;

  BackgroundGrid({
    super.key,
    required this.background,
    required this.metaTile,
    this.onTap,
    this.onHover,
    this.showGrid = false,
    this.cellSize = 40,
  });

  @override
  State<BackgroundGrid> createState() => _BackgroundGridState();
}

class _BackgroundGridState extends State<BackgroundGrid> {
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();

  int currentRow = 0;
  int currentCol = 0;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalController,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _verticalController,
        child: TableView.builder(
          verticalDetails:
              ScrollableDetails.vertical(controller: _verticalController),
          horizontalDetails:
              ScrollableDetails.horizontal(controller: _horizontalController),
          cellBuilder: _buildCell,
          columnCount: widget.background.width,
          columnBuilder: _buildColumnSpan,
          rowCount: widget.background.height,
          rowBuilder: _buildRowSpan,
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    int tileOrigin = context.read<BackgroundCubit>().state.tileOrigin;
    int mapIndex = vicinity.yIndex * widget.background.width + vicinity.xIndex;
    int tileIndex = widget.background.data[mapIndex];
    int maxTileIndex = (context.read<MetaTileCubit>().state.data.length ~/
            (context.read<MetaTileCubit>().state.height *
                context.read<MetaTileCubit>().state.width));
    int maxTileIndexWithOrigin = maxTileIndex + tileOrigin;
    bool valid = tileIndex < maxTileIndexWithOrigin &&
        widget.background.data[mapIndex] - tileOrigin >= 0;

    return TableViewCell(
      child: valid
          ? MetaTileDisplay(
              tileData: widget.metaTile.getTileAtIndex(
                  widget.background.data[mapIndex] - tileOrigin),
            )
          : FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${widget.background.data[mapIndex]}+$tileOrigin\n<=$maxTileIndex",
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
      ,
    );
  }

  TableSpan _buildColumnSpan(int index) {
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
          trailing: BorderSide(width: 1, color: Colors.lightBlue)),
    );

    return TableSpan(
        foregroundDecoration: widget.showGrid ? decoration : null,
        extent: FixedTableSpanExtent(widget.cellSize),
        onEnter: (_) => setState(() {
              currentCol = index;
              if (widget.onHover != null) {
                widget.onHover!(currentCol, currentRow);
              }
            }));
  }

  TableSpan _buildRowSpan(int index) {
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(width: 1, color: Colors.lightBlue),
      ),
    );

    return TableSpan(
      foregroundDecoration: widget.showGrid ? decoration : null,
      extent: FixedTableSpanExtent(widget.cellSize),
      onEnter: (_) => setState(() {
        currentRow = index;
        if (widget.onHover != null) {
          widget.onHover!(currentCol, currentRow);
        }
      }),
      recognizerFactories: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer t) => t.onTap = () =>
              widget.onTap!(currentRow * widget.background.width + currentCol),
        ),
      },
    );
  }
}
