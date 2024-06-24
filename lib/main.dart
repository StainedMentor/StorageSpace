
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storagespace/list_widget.dart';
import 'package:storagespace/pie.dart';
import 'scanner.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Sample data: List of slices with percentages and colors
  List<PieSliceData> slices = [
    PieSliceData(color: Colors.blue, percentage: 0.3, label: 'Smaller files', value: 1),
    PieSliceData(color: Colors.green, percentage: 0.2, label: 'Smaller files', value: 1),
    PieSliceData(color: Colors.orange, percentage: 0.15, label: 'Smaller files', value: 1),
    PieSliceData(color: Colors.red, percentage: 0.35, label: 'Smaller files', value: 1),
  ];

  FolderSizeCalculator scanner = FolderSizeCalculator(getRootPath()!);
  FileSystemNode base = FileSystemNode(name: "root", isFile: true, size: 0);
  List<FileSystemNode> filelist = [];

  GlobalKey key = GlobalKey();
  List<FileSystemNode> currentPath = [];

  var statusText = "Scanning drive...";


  @override
  void initState() {
    super.initState();
    readyMap();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Storage Space'),
        ),
        body: 
        Row(
          children: [
            Expanded(child: 
            FileSystemWidget(nodes: filelist,changeCallback: changeFolderInList, currentPath: currentPath)),
            Expanded(child: 
            Column(
              children: [
            Expanded(
              child: 
                  Padding(padding: EdgeInsets.all(40),
                  child: 
                    PieChart(
                        slices: slices,
                        radius: 150,
                        onPressed: (int index) {
                          sliceClicked(index);
                        },
                        key: key,
                        exitFolder: exitFolder
                      ),
                  )
                
            ),
            Container(
              width: 200,
              height: 50,
              child: 
            Text(statusText))
            ]))
          ]
        ),
      ),
    );
  }
  void changeFolderInList(List<FileSystemNode> nodePath) {
    currentPath = nodePath;
    if (base != null){

      while(base.parent != null) {
        base = base.parent!;
      }
      for (FileSystemNode node in nodePath){
        base = base.children.firstWhere((element) => element == node);
      }
      prepareSliceData();
      
    }
  }
  void exitFolder() {
    if (base != null){
    if (base.parent != null){
    base = base.parent!;
    prepareSliceData();
    currentPath.removeLast();
    }
    }
  }

  void sliceClicked(int index){
    if (!base.children.isEmpty){
      base = base.children[index];

      
      prepareSliceData();
      currentPath.add(base);
    }
  }

  void readyMap() async {
    base = await scanner.mapFileSystem();
    filelist = base.children;
    setState(() {
      statusText = "All done!";
    });

        prepareSliceData();
  }


  Future<void> prepareSliceData() async {

    base.children.sort((b, a) => a.size.compareTo(b.size));


    List<PieSliceData> tempList = [];


    var colors = generateGradientColors(36);
    if (base.children.length <=36) {
      for ( int i = 0; i < base.children.length; i++){
        
        tempList.add(PieSliceData(color: colors[i], percentage:  base.children[i].size/base.size, label: base.children[i].name, value: base.children[i].size));

      }
    }
    else {
      var totalPercent = 0.0;
      for ( int i = 0; i < 35; i++){
        var slicePercent = base.children[i].size/base.size;
        tempList.add(PieSliceData(color: colors[i], percentage:  slicePercent, label: base.children[i].name, value: base.children[i].size));

      }
        tempList.add(PieSliceData(color: colors[35], percentage:  1-totalPercent, label: 'Smaller files', value: 1));

    }


    setState(() {
          slices = tempList;
    });

  }
}



