import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:storagespace/scanner.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onFolderSelected;

  const Sidebar({required this.onFolderSelected});

  void _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      onFolderSelected(selectedDirectory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(5),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          ElevatedButton(
            onPressed: _selectFolder,
            child: const Text('Select Folder'),
          ),
          const SizedBox(height: 10,), 

          ElevatedButton(onPressed: () => {
            onFolderSelected(getRootPath()!)
          }, child: const Text('Scan full disk'))
        ],
      ),
    );
  }
}