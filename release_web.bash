#!/usr/bin/env bash
set -e

flutter build web --release --base-href /game_boy_graphics_editor/

cp -r build/web /tmp/game_boy_graphics_editor_web

git switch gh-pages
rm -rf -- *
cp -r /tmp/game_boy_graphics_editor_web/. .

git add -A
git commit -m "update web build"
git push origin gh-pages

git switch master

rm -rf /tmp/game_boy_graphics_editor_web