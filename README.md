# GameBoyGraphicsEditor (GBGE)

This is a graphic editor for [GBDK](https://github.com/gbdk-2020/gbdk-2020) inspired by 
[`GameBoyTileDesigner (GBTD)` and `GameBoyMapBuilder (GBMB)`](https://github.com/gbdk-2020/GBTD_GBMB).

# Online version

GBGE can be run in your browser !

https://odrevet.github.io/GameBoyGraphicsEditor

# Features

* GBGE aims to be compatible with .c exported from `GBTD and GBMB`, there are no 'project file', you
  import / export data directly from your source code.

* Save to C source file.

* Flood file

* Shift / rotate / flip tiles

* Load background data from C source file (exported from gbmb).

* All in one Tile and Map Editor.

* Made with Flutter : modern interface and can be build for Linux / Windows and Web !

* Free software under the GNU GENERAL PUBLIC LICENSE

# Compatibility with GBTD

GBGE has less options (no palette, no compression, no bin/z80 export)

the only mode available are these equivalants of these GBTD settings:

```
Form                 : All tiles as one unit.
Format               : Gameboy 4 color.
Compression          : None.
Palette colors       : None.
SGB Palette          : None.
CGB Palette          : None.

Convert to metatiles : No.
```

# References

[laroldsjubilantjunkyard.com](https://laroldsjubilantjunkyard.com/tutorials/how-to-make-a-gameboy-game/sprites-and-backgrounds/)