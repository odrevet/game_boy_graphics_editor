import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/grid_map.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

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
  late String raw;
  var mapData = List.filled(16, 0, growable: true);
  var tileData = List.filled(64, 0, growable: true);
  var selectedIntensity = 0;
  var tileSize = 8;
  var tileCount = 1;
  var tileIndex = 0;
  bool tileMode = true; // edit tile or map
  String name = "data";

  @override
  void initState() {
    raw = getRawFromIntensity(tileData, tileSize).join(',');
    super.initState();
  }

  Future<void> _saveFile() async {
    String? fileName =
        await FilePicker.platform.saveFile(allowedExtensions: [".c"]);
    if (fileName != null) {
      File file = File(fileName);
      file.writeAsString("unsigned char $name[] =\n{\n$raw};");
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
          raw = values;
          this.name = name;
          tileData.clear();
          tileData = getIntensityFromRaw(raw.split(','), tileSize);
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
        appBar: AppBar(
          title: Text(
              "$name tile #$tileIndex selected. $tileCount tile(s) total"),
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
                      raw =
                          getRawFromIntensity(tileData, tileSize).join(',');
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
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: tileMode
              ? [
                  _tileListView(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: PixelGridWidget(
                          onTap: _setPixel,
                          intensity: tileData.sublist(
                              (tileSize * tileSize) * tileIndex,
                              (tileSize * tileSize) * (tileIndex + 1))),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridMap(
                            mapData: List.filled(16, tileIndex, growable: false),
                            tileData: tileData,
                            tileSize: tileSize,
                            onTap: null,
                          ),
                        ),
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SelectableText(raw),
                        )),
                      ],
                    ),
                  )
                ]
              : [
                  _tileListView(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridMap(
                      mapData: mapData,
                      tileData: tileData,
                      tileSize: tileSize,
                      onTap: (index) => setState(() {
                        mapData[index] = tileIndex;
                      }),
                    ),
                  )
                ],
        ));
  }

  Widget _tileListView() {
    return SizedBox(
        width: 200,
        child: ListView.builder(
          itemCount: tileCount,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        indent: 20.0,
                        endIndent: 10.0,
                        thickness: 1,
                      ),
                    ),
                    Text(
                      "$index",
                      style: const TextStyle(color: Colors.green),
                    ),
                    const Expanded(
                      child: Divider(
                        indent: 10.0,
                        endIndent: 20.0,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() {
                    tileIndex = index;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PixelGridWidget(
                        intensity: tileData.sublist(
                            (tileSize * tileSize) * index,
                            (tileSize * tileSize) * (index + 1))),
                  ),
                )
              ],
            );
          },
        ));
  }

  _setPixel(int index) {
    index += (tileSize * tileSize) * tileIndex;
    setState(() {
      tileData[index] = selectedIntensity;
      raw = getRawFromIntensity(tileData, tileSize).join(",");
    });
  }
}
