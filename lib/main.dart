import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/map_widget.dart';
import 'package:gbdk_graphic_editor/widgets/tile_list_view.dart';
import 'package:gbdk_graphic_editor/widgets/tile_widget.dart';

import 'colors.dart';
import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBDK Graphic Editor',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const Editor(),
    );
  }
}

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int mapHeight = 1;
  int mapWidth = 1;
  var mapData = List.filled(1, 0, growable: true);
  var tileData = List.filled(64, 0, growable: true);
  var selectedIntensity = 0;
  var tileSize = 8;
  var tileCount = 1;
  var tileIndex = 0;
  bool tileMode = true; // edit tile or map
  String name = "data";

  Future<void> _saveFile() async {
    String? fileName =
        await FilePicker.platform.saveFile(allowedExtensions: [".c"]);
    if (fileName != null) {
      File file = File(fileName);
      file.writeAsString(
          "unsigned char $name[] =\n{\n${getRawFromIntensity(tileData, tileSize).join(",")};");
    }
  }

  void _selectFolder() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['c'],
    );

    if (result != null) {
      late String source = "";
      if (kIsWeb) {
        Uint8List? bytes = result.files.single.bytes;
        source = String.fromCharCodes(bytes!);
      } else {
        File file = File(result.files.single.path!);
        source = await file.readAsString();
      }

      RegExp regExp = RegExp(r"unsigned char (\w+)\[\] =\n\{\n([\s\S]*)};");
      var matches = regExp.allMatches(source);

      var name = "";
      var values = "";

      for (Match match in matches) {
        name = match.group(1)!;
        values = match.group(2)!;
      }

      if (name != "" && values.isNotEmpty) {
        setState(() {
          this.name = name;
          tileData.clear();
          tileData = getIntensityFromRaw(values.split(','), tileSize);
          tileIndex = 0;
          tileCount = tileData.length ~/ (tileSize * tileSize);
        });
      }
    }
  }

  Widget intensityButton(int buttonIntensity) {
    return IconButton(
        icon: Icon(Icons.stop, color: colors[buttonIntensity]),
        onPressed: () => setState(() {
              selectedIntensity = buttonIntensity;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: tileMode ? _buildTile() : _buildMap(),
        ));
  }

  _buildAppBar() {
    return AppBar(
      title: Text("$name tile #$tileIndex selected. $tileCount tile(s) total"),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.white,
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => setState(() {
                  tileMode = !tileMode;
                }),
            child: Text(tileMode == true ? 'tile' : 'Map')),
        intensityButton(0),
        intensityButton(1),
        intensityButton(2),
        intensityButton(3),
        IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add tile',
            onPressed: () => setState(() {
                  tileCount += 1;
                  tileData += List.filled(64, 0);
                })),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip:
              kIsWeb ? 'Save is not available for web' : 'Save source file',
          onPressed: kIsWeb ? null : _saveFile,
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open source file',
          onPressed: _selectFolder,
        )
      ],
    );
  }

  _buildTile() {
    var tileListView = TileListView(
      onTap: (index) => setState(() {
        tileIndex = index;
      }),
      tileCount: tileCount,
      tileData: tileData,
      tileSize: tileSize,
    );

    return [
      tileListView,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TileWidget(
              onTap: _setPixel,
              intensity: tileData.sublist((tileSize * tileSize) * tileIndex,
                  (tileSize * tileSize) * (tileIndex + 1))),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MapWidget(
                mapHeight: 4,
                mapWidth: 4,
                mapData: List.filled(16, tileIndex, growable: false),
                tileData: tileData,
                tileSize: tileSize,
                onTap: null,
              ),
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                  getRawFromIntensity(tileData, tileSize).join(",")),
            )),
          ],
        ),
      )
    ];
  }

  _buildMap() {
    var tileListView = TileListView(
      onTap: (index) => setState(() {
        tileIndex = index;
      }),
      tileCount: tileCount,
      tileData: tileData,
      tileSize: tileSize,
    );

    return [
      tileListView,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MapWidget(
          mapHeight: mapHeight,
          mapWidth: mapWidth,
          mapData: mapData,
          tileData: tileData,
          tileSize: tileSize,
          onTap: (index) => setState(() {
            mapData[index] = tileIndex;
          }),
        ),
      ),
      Flexible(
        child: Column(
          children: [
            Text('Height $mapHeight'),
            TextField(
              onChanged: (text) => setState(() {
                mapHeight = int.parse(text);
                mapData = List.filled(mapHeight * mapWidth, 0);
              }),
            ),
            Text('Width $mapWidth'),
            TextField(
              onChanged: (text) => setState(() {
                mapWidth = int.parse(text);
                mapData = List.filled(mapHeight * mapWidth, 0);
              }),
            ),
            Flexible(
              child:
                  SelectableText(mapData.map((e) => decimalToHex(e)).join(",")),
            ),
          ],
        ),
      )
    ];
  }

  _setPixel(int index) {
    index += (tileSize * tileSize) * tileIndex;
    setState(() {
      tileData[index] = selectedIntensity;
    });
  }
}
