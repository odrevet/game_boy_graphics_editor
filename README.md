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

![linda](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/import.png)
![linda](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/preview.png)
![linda](https://raw.githubusercontent.com/odrevet/game_boy_graphics_editor/main/screenshots/editor.png)

# web release

## build

```
flutter build web --release
```

Then remove `<base href="/">` from `build/web/index.html`

## test

```
python -m http.server 8000 -d build/web
```

## deploy to github pages

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
