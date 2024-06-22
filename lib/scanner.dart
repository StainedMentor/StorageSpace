
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';




// Function to get the path of the Desktop directory
Future<String?> getDesktopDirectory() async {
  // try {
  //   Directory homeDir = await getApplicationSupportDirectory();
  //   String homePath = homeDir.parent.parent.path; // Navigate to home directory

  //   print("Home Directory: $homePath"); // Debug: Print the home directory

  //   String desktopPath;
  //   if (Platform.isWindows) {
  //     desktopPath = '$homePath\\Desktop';
  //   } else if (Platform.isMacOS || Platform.isLinux) {
  //     desktopPath = '$homePath/Desktop';
  //   } else {
  //     // Handle other platforms or return null if not applicable
  //     return null;
  //   }

  //   print("Detected Desktop Path: $desktopPath"); // Debug: Print the desktop path

  //   // Check if the directory exists
  //   if (Directory(desktopPath).existsSync()) {
  //     return desktopPath;
  //   } else {
  //     print("Desktop directory does not exist.");
  //     return null;
  //   }
  // } catch (e) {
  //   print("Error locating Desktop folder: $e");
  //   return null;
  // }
  return "/Users/oli/Desktop";
}


// Function to format bytes into human-readable format
String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = (log(bytes) / log(1024)).floor(); // Calculate log base 1024
  double num = bytes / pow(1024, i);
  return "${num.toStringAsFixed(decimals)} ${suffixes[i]}";
}








class FileSystemNode {
  final String name;
  final bool isFile;
  final int size;
  List<FileSystemNode> children = [];
  FileSystemNode? parent = null;

  FileSystemNode({
    required this.name,
    required this.isFile,
    required this.size,
    this.parent

  });

  @override
  String toString() {
    return _toString(0);
  }

  String _toString(int indent) {
    final indentStr = '  ' * indent;
    final type = isFile ? 'File' : 'Folder';
    final sizeStr = isFile ? ' (${size} bytes)' : '';
    final result = StringBuffer('$indentStr$type: $name$sizeStr\n');
    if (children != null) {
      for (var child in children!) {
        result.write(child._toString(indent + 1));
      }
    }
    return result.toString();
  }
}


class FolderSizeCalculator {
  final String folderPath;

  FolderSizeCalculator(this.folderPath);

  Future<FileSystemNode> mapFileSystem() async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      throw Exception("Directory does not exist");
    }
    return await _mapDirectory(directory);
  }

  Future<FileSystemNode> _mapDirectory(Directory directory) async {
    final List<FileSystemNode> children = [];
    int totalSize = 0;

    await for (FileSystemEntity entity in directory.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        
        var size = 0;
        try {
          size = await entity.length();
        }
        catch (e) {
          print(e);
        }
        children.add(FileSystemNode(
          name: entity.uri.pathSegments.last,
          isFile: true,
          size: size,
        ));
        totalSize += size;

      } else if (entity is Directory) {
        try {
        FileSystemNode child = await _mapDirectory(entity);
        children.add(child);
        totalSize +=  child.size!;
        }catch (e) {
    print('Failed to access the directory: $e');
  }
      }
    }
    var outNode = FileSystemNode(
      name: directory.uri.pathSegments.isEmpty ? directory.path : directory.uri.pathSegments[directory.uri.pathSegments.length-2],
      isFile: false,
      size: totalSize,
    );
    for (int i=0; i< children.length; i++){
      children[i].parent = outNode;
      
    }
    outNode.children = children;

    return  outNode;
  }
}


  List<Color> generateGradientColors(int numSteps) {
    List<Color> colors = [];

    for (int i = 0; i < numSteps; i++) {
      double hue = (i * 360 / numSteps) % 360;
      Color color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
      colors.add(color);
    }

    return colors;
  }