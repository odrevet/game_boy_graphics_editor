import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_parser.dart';

import '../models/file_picker_utils.dart';

class GraphicForm extends StatefulWidget {
  final String title;
  final String? initialName;
  final int? initialWidth;
  final int? initialHeight;
  final int? initialTileOrigin;
  final Function(String name, int width, int height, int tileOrigin) onSubmit;

  const GraphicForm({
    Key? key,
    required this.title,
    required this.onSubmit,
    this.initialName,
    this.initialWidth,
    this.initialHeight,
    this.initialTileOrigin,
  }) : super(key: key);

  @override
  State<GraphicForm> createState() => GraphicFormState();
}

class GraphicFormState extends State<GraphicForm> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _tileOriginController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _widthController = TextEditingController(
      text: widget.initialWidth?.toString() ?? '8',
    );
    _heightController = TextEditingController(
      text: widget.initialHeight?.toString() ?? '8',
    );
    _tileOriginController = TextEditingController(
      text: widget.initialTileOrigin?.toString() ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(widget.title)),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'file') {
                _readPropertiesFromFile();
              } else if (value == 'clipboard') {
                _readPropertiesFromClipboard();
              }
            },
            icon: const Icon(Icons.article),
            tooltip: 'Load Properties',
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'file',
                child: ListTile(
                  leading: Icon(Icons.file_open),
                  title: Text('Load from file'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clipboard',
                child: ListTile(
                  leading: Icon(Icons.content_paste),
                  title: Text('Load from clipboard'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter width';
                  final width = int.tryParse(value);
                  if (width == null || width < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter height';
                  final height = int.tryParse(value);
                  if (height == null || height < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tileOriginController,
                decoration: const InputDecoration(labelText: 'Tile Origin'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter tile origin';
                  final origin = int.tryParse(value);
                  if (origin == null || origin < 0)
                    return 'Please enter a valid non-negative number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text.trim();
              final width = int.parse(_widthController.text);
              final height = int.parse(_heightController.text);
              final tileOrigin = int.parse(_tileOriginController.text);

              Navigator.of(context).pop();
              widget.onSubmit(name, width, height, tileOrigin);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  _readPropertiesFromFile() async {
    final result = await selectFile(['*']);
    if (result == null) return null;

    final source = await readString(result);
    _parseAndSetProperties(source);
  }

  _readPropertiesFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        _parseAndSetProperties(clipboardData!.text!);
      }
    } catch (e) {
      // Handle clipboard access error if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read from clipboard')),
        );
      }
    }
  }

  void _parseAndSetProperties(String source) {
    Map<String, int> defines = SourceParser().readDefinesFromSource(
      source,
    );

    defines.forEach((key, value) {
      if (key.endsWith('TILE_ORIGIN')) {
        _tileOriginController.text = value.toString();
      } else if (key.endsWith('WIDTH')) {
        _widthController.text = value.toString();
      } else if (key.endsWith('HEIGHT')) {
        _heightController.text = value.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _tileOriginController.dispose();
    super.dispose();
  }
}
