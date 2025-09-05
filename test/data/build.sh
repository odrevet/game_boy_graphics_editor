png2asset numbers.png -map
png2asset numbers.png -o "numbers_transposed.c" -transposed -map

png2asset numbers.png -map -maps_only -bin
gbcompress numbers_map.bin number_map_compressed.bin

png2asset numbers.png -map -tiles_only -bin
gbcompress numbers_tiles.bin number_tiles_compressed.bin