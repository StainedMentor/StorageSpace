
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;


import 'dart:io';
import 'dart:math';


/// Class used to create tree nodes of the file system
class FileSystemNode {
  String name;
  final bool isFile;
  final int size;
  List<FileSystemNode> children = [];
  FileSystemNode? parent;

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
    final sizeStr = isFile ? ' ($size bytes)' : '';
    final result = StringBuffer('$indentStr$type: $name$sizeStr\n');
    for (var child in children) {
      result.write(child.name);
    }
      return result.toString();
  }

  String getFullPath() {
    var fullPath = "";
    var currentNode = this;

    while (currentNode.parent != null) {
      fullPath = path.join(currentNode.name, fullPath);
      currentNode = currentNode.parent!;
    }

    fullPath = path.join(currentNode.name, fullPath);

    return fullPath;
  }
}

class FolderSizeCalculator {
  final String folderPath;
  final StreamController<int> _fileCountController = StreamController<int>();

  FolderSizeCalculator(this.folderPath);

  /// Stream of the current total files scanned
  Stream<int> get fileCountStream => _fileCountController.stream;
  int totalScanned = 0; // Track the number of files scanned

  Future<FileSystemNode> mapFileSystem() async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      throw Exception("Directory does not exist");
    }
    var topNode = await _mapDirectory(directory);
    
    topNode.name = folderPath;
    _fileCountController.close(); // Close the stream controller when done
    return topNode;
  }

  Future<FileSystemNode> _mapDirectory(Directory directory) async {
    final List<FileSystemNode> children = [];
    int totalSize = 0;

    final List<Future> tasks = [];
await for (FileSystemEntity entity in directory.list(recursive: false, followLinks: false)) {
      if (entity is Link) {

      }
      else if (entity is File) {
        tasks.add(() async {
          var size = 0;
          try {
            size = await entity.length();
          } catch (e) {
            developer.log(e.toString());
          }

          children.add(FileSystemNode(
            name: entity.uri.pathSegments.last,
            isFile: true,
            size: size,
          ));

          totalSize += size;
          totalScanned += size;

          // Emit the updated total size
          _fileCountController.add(totalScanned);
        }());
      } else if (entity is Directory) { 
        tasks.add(() async {
          if (entity.path != "/System/Volumes"){
          try {
            FileSystemNode child = await _mapDirectory(entity);
            children.add(child);
            totalSize += child.size;
          } catch (e) {
            developer.log('Failed to access the directory: $e');
          }
          }
        }());
      }
    }
    await Future.wait(tasks);


    var outNode = FileSystemNode(
      name: directory.uri.pathSegments.isEmpty ? directory.path : directory.uri.pathSegments[directory.uri.pathSegments.length - 2],
      isFile: false,
      size: totalSize,
    );

    for (int i = 0; i < children.length; i++) {
      children[i].parent = outNode;
    }

    outNode.children = children;

    return outNode;
  }

  // Dispose method to clean up the stream controller if needed
  void dispose() {
    _fileCountController.close();
  }
}

// UTILITY Functions



  /// Returns the root path for current platform
String? getRootPath() {
  if (Platform.isMacOS || Platform.isLinux) {
    return "/";
  } 
  else if (Platform.isWindows) {
    return "C: ";
  }
  else {
    return null;
  }
}


/// Function to get the path of the Desktop directory for the current platform
/// 
/// This function assumes that desktop is always a subfolder of the homepath
String? getDesktopDirectory() {
  try {
    String? home = "";
    String? desktopPath;

    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS || Platform.isLinux) {
      home = envVars['HOME'];
    } 
    else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    else {
      return null;
    }

    developer.log("Home path: $home");
    

    if (Platform.isWindows) {
      desktopPath = '$home\\Desktop';
    } else if (Platform.isMacOS || Platform.isLinux) {
      desktopPath = '$home/Desktop';
    } else {
      return null;
    }

    // Check if the directory exists
    if (Directory(desktopPath).existsSync()) {
      return desktopPath;
    } else {
      developer.log("Desktop directory does not exist.");
      return null;
    }
  } catch (e) {
    developer.log("Error locating Desktop folder: $e");
    return null;
  }
}

/// Function to format bytes into highest order unit
/// 
/// The base for the conversion is adjusted for the current platform
String formatBytes(int bytes, int decimals, ) {
  var base = 1000;
  if (Platform.isWindows){
    base = 1024;
  }
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = (log(bytes) / log(base)).floor(); 
  double num = bytes / pow(base, i);
  return "${num.toStringAsFixed(decimals)} ${suffixes[i]}";
}


/// Return a list of different colors
List<Color> generateGradientColors(int numSteps) {
  List<Color> colors = [];

  for (int i = 0; i < numSteps; i++) {
    double hue = i.toDouble()/numSteps*360;
    Color color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    colors.add(color);
  }

  return colors;
}