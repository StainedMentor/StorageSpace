import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storagespace/scanner.dart';
import 'dart:developer' as developer;




class FileSystemWidget extends StatefulWidget {
  final FileSystemNode? base;
  final ValueChanged<List<FileSystemNode>> changeCallback;
  List<FileSystemNode> currentPath;


  FileSystemWidget({super.key, required this.base, required this.changeCallback, required this.currentPath});

  @override
  _FileSystemWidgetState createState() => _FileSystemWidgetState();
}

class _FileSystemWidgetState extends State<FileSystemWidget> {
  // Current path in the file system as list of nodes
  List<FileSystemNode> _currentPath = [];
  String currentBaseName = '';
  String currentPathString = '';


  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPathString.isEmpty ? 'Select a Folder' : currentPathString),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,

        child: Row(
          children: _buildFileSystemColumns(),
        ),
      ),
    );
  }

  List<Widget> _buildFileSystemColumns() {
    List<Widget> columns = [];
    List<FileSystemNode> currentLevel =  [] ;
    if (widget.base != null){
      currentBaseName = widget.base!.name.split('/').last;
      currentLevel = widget.base!.children;
    }
    

    currentLevel.sort((b, a) => a.size.compareTo(b.size));

    // Root column
    columns.add(_buildNodeList(currentLevel, 'Root'));


    // Add columns for each level in the current path
    for (var i = 0; i < _currentPath.length; i++) {
      var node = _currentPath[i];
      node.children.sort((b, a) => a.size.compareTo(b.size));

      columns.add(_buildNodeList(node.children, node.name));

    }

    // Add scrolling horizontally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    return columns;
  }

  Widget _buildNodeList(List<FileSystemNode> nodes, String columnTitle) {
    return Container(
      width: 300, 
      margin: const EdgeInsets.only(right: 4.0), 
      child: Column(
        children: [
          // close button
          ElevatedButton(
            onPressed: () {
              setState(() {
                int index = widget.currentPath.indexWhere((element) => element.name == columnTitle);

                if (index != -1) {
                  widget.currentPath = widget.currentPath.sublist(0, index+1);
                } else {
                  widget.currentPath.clear();
                }

                _currentPath = widget.currentPath;
                widget.changeCallback(widget.currentPath);
                _updatePathString();

               
              });
            },
            child: Text(columnTitle),
          ),
          Expanded(
            child: ListView(
              children: nodes.map((node) => _buildNodeWidget(node)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(FileSystemNode node) {


    return     GestureDetector(
            onSecondaryTapUp: (details) {
                _showContextMenu(context, node, details);

            },
            child:  ListTile(
      title: Text(node.name),
      trailing:  Text(formatBytes(node.size, 2)),
      onTap: () {
        if (!node.isFile) {
          setState(() {
            // When a directory is clicked, set the current path to include only up to this directory
            int index = widget.currentPath.indexWhere((element) => element == node.parent);
            widget.currentPath = widget.currentPath.sublist(0, index + 1);
            widget.currentPath.add(node);


            _currentPath = widget.currentPath;
            widget.changeCallback(widget.currentPath);
            _updatePathString();

          });
        }
      },
      
    ));
    
    
  }
    void _showContextMenu(BuildContext context, FileSystemNode node, TapUpDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset globalOffset =  details.globalPosition;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        globalOffset & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
      items: [
        const PopupMenuItem(
          value: 0,
          child: Text('Open in file system'),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text('Add to collector'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleContextMenuAction(value, node);
      }
    });
  }

  void _handleContextMenuAction(int action, FileSystemNode node) {
    if (action == 0) {
        revealInFileSystem(node.getFullPath());
    }
    else {

    }
  }
    static const platform = MethodChannel('samples.flutter.dev/finder');

   Future<void> revealInFileSystem(String path) async {
    try {
      await platform.invokeMethod('revealInFileSystem', {"path": path});
    } on PlatformException catch (e) {
      developer.log("Failed to reveal file: ${e.message}");
    }
  }
    void _updatePathString() {
    List<String> pathNames = [currentBaseName];

    for (var node in _currentPath) {
      pathNames.add(node.name);
    }
    setState(() {
      currentPathString = pathNames.join(' > ');

    });

  }


}