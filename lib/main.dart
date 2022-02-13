import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

import 'utils.dart';
import 'colors.dart';

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
  String raw = "";
  var intensity = List.filled(64, 0, growable: true);
  var selectedIntensity = 0;
  var spriteSize = 8;
  var spriteCount = 1;
  var spriteIndex = 0;
  String name = "";

  void _selectFolder() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['c'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final source = await file.readAsString();

      RegExp regExp = RegExp(r"unsigned char (\w+)\[\] =\r\n\{\r\n([\s\S]*)};");
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

  Widget intensityButton(int intensity) {
    return IconButton(
        icon: Icon(Icons.stop, color: colors[intensity]),
        onPressed: () => setState(() {
              selectedIntensity = intensity;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$name Sprite #$spriteIndex selected. $spriteCount sprite(s) total"),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => getRawFromIntensity(intensity, spriteSize),
            ),
            intensityButton(0),
            intensityButton(1),
            intensityButton(2),
            intensityButton(3),
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
                child: ListView.separated(
                  itemCount: spriteCount,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Text("$index"),
                        InkWell(
                          onTap: () => setState(() {
                            spriteIndex = index;
                          }),
                          child: PixelGridWidget(
                              intensity: intensity.sublist(
                                  (spriteSize * spriteSize) * index,
                                  (spriteSize * spriteSize) * (index + 1))),
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                )),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: PixelGridWidget(
                  onTap: _setPixel,
                  intensity: intensity.sublist(
                      (spriteSize * spriteSize) * spriteIndex,
                      (spriteSize * spriteSize) * (spriteIndex + 1))),
            ),
            Flexible(
              child: Column(
                children: [
                  Flexible(child: Text(raw)),
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
    });
  }
}
