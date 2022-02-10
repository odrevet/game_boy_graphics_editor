import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gbdk_graphic_editor/widgets/pixel_grid.dart';

import 'widgets/pixel.dart';

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
  var intensity = List.filled(64, 0, growable: false);
  var arr = <int>[];
  var spriteSize = 8;
  var spriteCount = 0;
  var spriteIndex = 0;



  String _convertToBinary(String hex) {
    return int.parse(hex).toRadixString(2).padLeft(spriteSize, "0");
  }

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
      var values = [];

      for (Match match in matches) {
        name = match.group(1)!;
        values = match.group(2)!.split(',');
      }

      if (name != "" && values.isNotEmpty) {
        setState(() {
          arr.clear();
        });

        for (var index = 0; index < values.length; index += 2) {
          var lo = _convertToBinary(values[index]);
          var hi = _convertToBinary(values[index + 1]);

          var combined = "";
          for (var index = 0; index < spriteSize; index++) {
            combined += hi[index] + lo[index];
          }

          for (var index = 0; index < spriteSize * 2; index += 2) {
            setState(() {
              arr.add(
                  int.parse(combined[index] + combined[index + 1], radix: 2));
            });
          }
        }

        setState(() {
          spriteIndex = 0;
          spriteCount = arr.length ~/ (spriteSize * spriteSize);
          intensity = arr.sublist((spriteSize * spriteSize) * spriteIndex,
              (spriteSize * spriteSize) * (spriteIndex + 1));
        });
      }
    }
  }

  _spriteIndexDown() {
    if (spriteIndex > 0) {
      setState(() {
        spriteIndex -= 1;
        intensity = arr.sublist((spriteSize * spriteSize) * spriteIndex,
            (spriteSize * spriteSize) * (spriteIndex + 1));
      });
    }
  }

  _spriteIndexUp() {
    if(spriteIndex + 1 < spriteCount) {
      setState(() {
        spriteIndex += 1;
        intensity = arr.sublist((spriteSize * spriteSize) * spriteIndex,
            (spriteSize * spriteSize) * (spriteIndex + 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              tooltip: 'Sprite index down',
              onPressed: _spriteIndexDown,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              tooltip: 'Sprite index up',
              onPressed: _spriteIndexUp,
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Open source file',
              onPressed: _selectFolder,
            )
          ],
        ),
        body: PixelGridWidget(intensity: intensity));
  }
}
