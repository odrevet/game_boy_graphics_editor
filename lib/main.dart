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
  var intensity = List.filled(64, 0, growable: true);
  var selectedIntensity = 0;
  var spriteSize = 8;
  var spriteCount = 1;
  var spriteIndex = 0;
  String name = "data";

  @override
  void initState() {
    raw = getRawFromIntensity(intensity, spriteSize).join(',');
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
          intensity.clear();
          intensity = getIntensityFromRaw(raw.split(','), spriteSize);
          spriteIndex = 0;
          spriteCount = intensity.length ~/ (spriteSize * spriteSize);
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
              "$name Sprite #$spriteIndex selected. $spriteCount sprite(s) total"),
          actions: [
            intensityButton(0),
            intensityButton(1),
            intensityButton(2),
            intensityButton(3),
            IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add sprite',
                onPressed: () => setState(() {
                      spriteCount += 1;
                      intensity += List.filled(64, 0);
                      raw =
                          getRawFromIntensity(intensity, spriteSize).join(',');
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
          children: [
            SizedBox(
                width: 200,
                child: ListView.builder(
                  itemCount: spriteCount,
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
                            spriteIndex = index;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PixelGridWidget(
                                intensity: intensity.sublist(
                                    (spriteSize * spriteSize) * index,
                                    (spriteSize * spriteSize) * (index + 1))),
                          ),
                        )
                      ],
                    );
                  },
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: PixelGridWidget(
                    onTap: _setPixel,
                    intensity: intensity.sublist(
                        (spriteSize * spriteSize) * spriteIndex,
                        (spriteSize * spriteSize) * (spriteIndex + 1))),
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridMap(
                      intensity: intensity,
                      spriteIndex: spriteIndex,
                      spriteSize: spriteSize,
                    ),
                  ),
                  Flexible(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(raw),
                  )),
                ],
              ),
            )
          ],
        ));
  }

  _setPixel(int index) {
    index += (spriteSize * spriteSize) * spriteIndex;
    setState(() {
      intensity[index] = selectedIntensity;
      raw = getRawFromIntensity(intensity, spriteSize).join(",");
    });
  }
}
