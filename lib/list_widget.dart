import 'package:flutter/material.dart';
import 'package:storagespace/scanner.dart';



class FileSystemWidget extends StatefulWidget {
  final List<FileSystemNode> nodes;
  final ValueChanged<List<FileSystemNode>> changeCallback;
  List<FileSystemNode> currentPath;


  FileSystemWidget({super.key, required this.nodes, required this.changeCallback, required this.currentPath});

  @override
  _FileSystemWidgetState createState() => _FileSystemWidgetState();
}

class _FileSystemWidgetState extends State<FileSystemWidget> {
  // Current path in the file system as list of nodes
  List<FileSystemNode> _currentPath = [];

  String currentPathString = '';
  


  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPathString.isEmpty ? 'Current Folder' : currentPathString),
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
    List<FileSystemNode> currentLevel = widget.nodes;

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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    return columns;
  }

  Widget _buildNodeList(List<FileSystemNode> nodes, String columnTitle) {
    return Container(
      width: 300, 
      margin: EdgeInsets.only(right: 4.0), 
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
    return ListTile(
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
    );
  }
    void _updatePathString() {
    List<String> pathNames = ['Root'];
    for (var node in _currentPath) {
      pathNames.add(node.name);
    }
    setState(() {
      currentPathString = pathNames.join(' > ');

    });

  }


}