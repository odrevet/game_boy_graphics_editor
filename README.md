# GameBoyGraphicsEditor (GBGE)

This is a graphic editor for [GBDK](https://github.com/gbdk-2020/gbdk-2020) inspired by 
[`GameBoyTileDesigner (GBTD)` and `GameBoyMapBuilder (GBMB)`](https://github.com/gbdk-2020/GBTD_GBMB). 

# Online version

GBGE can be run in your browser !

https://odrevet.github.io/GameBoyGraphicsEditor

# Features

* Load Tile data from C source file (exported from gbtd) or png (desktop only).

* Save to C source file.

* Flood file

* Shift / rotate / flip tiles

* Load background data from C source file (exported from gbmb).

# Pro and Cons over GBTD and GBMB

## Pro

* GBGE aims to be compatible with .c exported from `GBTD and GBMB`, there are no 'project file', you 
import / export data directly from your source code. 

* All in one Tile and Map Editor. 

* Made with Flutter : modern interface and can be build for Linux / Windows and Web ! 

* Free software under the GNU GENERAL PUBLIC LICENSE

## Cons

* Less options (no palette, no compression, no bin/z80 export)
  
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

* No undo / Redo

* Background editor slow in web build

# References

[laroldsjubilantjunkyard.com](https://laroldsjubilantjunkyard.com/tutorials/how-to-make-a-gameboy-game/sprites-and-backgrounds/)