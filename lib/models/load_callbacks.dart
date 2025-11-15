import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';

import '../cubits/app_state_cubit.dart';
import '../cubits/background_cubit.dart';
import '../cubits/meta_tile_cubit.dart';
import 'graphics/background.dart';
import 'graphics/graphics.dart';


bool loadMetaTile(Graphics graphics, BuildContext context, int tileOrigin) {
  bool hasLoaded = true;
  try {
    MetaTile metaTile;

    if (graphics is MetaTile) {
      metaTile = graphics;
    } else {
      final targetWidth = context.read<MetaTileCubit>().state.width;
      final targetHeight = context.read<MetaTileCubit>().state.height;
      metaTile = MetaTile.fromGraphics(
        graphics,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
    }

    context.read<MetaTileCubit>().addTileAtOrigin(metaTile, tileOrigin);
    context.read<AppStateCubit>().setTileName(graphics.name);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully loaded "${graphics.name}" as tiles'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print("ERROR $e");
    }
    hasLoaded = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to load "${graphics.name}" as tiles: ${e.toString()}',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  if (hasLoaded) {
    context.read<AppStateCubit>().setSelectedTileIndex(tileOrigin);
  }

  return hasLoaded;
}

void loadBackground(Graphics graphics, BuildContext context) {
  try {
    Background background;
    if (graphics is Background) {
      background = graphics;
    } else {
      background = Background.fromGraphics(graphics);
    }

    context.read<BackgroundCubit>().setWidth(background.width);
    context.read<BackgroundCubit>().setHeight(background.height);
    context.read<BackgroundCubit>().setData(background.data);
    context.read<BackgroundCubit>().setName(background.name);
    context.read<AppStateCubit>().setBackgroundName(background.name);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully loaded "${graphics.name}" as background'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to load "${graphics.name}" as background: ${e.toString()}',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
