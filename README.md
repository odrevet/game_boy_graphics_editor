This is a graphic editor compatible with [GBDK png2asset](https://github.com/gbdk-2020/gbdk-2020), 
[`GameBoyTileDesigner (GBTD)` and `GameBoyMapBuilder (GBMB)`](https://github.com/gbdk-2020/GBTD_GBMB) 

# Online version

game_boy_graphics_editor can run in a browser !

https://odrevet.github.io/game_boy_graphics_editor

# Features

* import / export data (tiles and background maps )directly from C source code or binary data
* Save to C source file.
* Editor: Flood file, Shift / rotate / flip tiles

# Screenshots

# Screenshots

| Import | Preview |
|--------|---------|
| [![Import](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/import.png)](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/import.png) | [![Preview](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/preview.png)](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/preview.png) |

| Editor | Export |
|--------|--------|
| [![Editor](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/editor.png)](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/editor.png) | [![Export](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/export.png)](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/export.png) |
# How to Use

## Workflow Overview

The Game Boy Graphics Editor follows a simple import-edit-export workflow. 

You bring graphics into the Memory Manager, load them into editors for modification, then export 

them back to your project.

## Import Graphics

Import graphics into the Memory Manager from three sources:

- **File**: Load from your local file system
- **URL**: Download directly from the web (desktop only)
- **Clipboard**: Paste source code directly

The importer supports multiple data types (auto-detect, source code, or binary) and automatically 

detects graphic types based on filename. 

Files ending with "tiles" are imported as Tiles, while files ending with "maps" 

become Backgrounds. You can manually override this using the toggle buttons.

## Memory Manager

The Memory Manager is your central hub for organizing graphics. Here you can:

- View all imported graphics with their dimensions and size
- Preview graphics before loading them into editors
- Edit properties like name, dimensions, and tile origin
- Delete graphics you no longer need

Each graphic shows an icon indicating whether it's a Background or Tiles

## Editing

Load graphics from the Memory Manager into the appropriate editor:

**Tile Editor** - For editing individual 8x8 pixel tiles. 

The editor supports standard drawing tools (pencil, line, rectangle, fill) plus tile-specific 

operations like rotate, flip, and copy/paste.

**Background Editor** - For editing tilemap layouts.

Edit the grid by placing tiles, and resize by adding or removing rows and columns.

Both editors feature full undo/redo support, a 4-color Game Boy palette, and optional grid display. 

## Export

After editing, commit your changes back to the Graphics Manager. From there, export your graphics in 

multiple formats:

- **C Source Code**: GBDK-compatible arrays with optional compression (RLE or GB-Compress)
- **PNG Image**: Visual export for documentation or sharing
- **Binary Data**: Raw binary files for custom toolchains

You can export individual graphics or multiple selections, choose specific tile ranges, and 

configure compression per export.


# How to build

## Linux
```
flutter build linux --release
```

## Web

* build

```
flutter build web --release
```

Then remove `<base href="/">` from `build/web/index.html`

* test using a local web server

```
python -m http.server 8000 -d build/web
```

* deploy to github pages

```
cp -r build/web ~/Documents/
git checkout gh-pages
rm -rf *
mv ~/Documents/web/* .
git add .
git commit -m "update web build"
git push
git checkout main
```

# References

[laroldsjubilantjunkyard.com](https://laroldsjubilantjunkyard.com/tutorials/how-to-make-a-gameboy-game/sprites-and-backgrounds/)
