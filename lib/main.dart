
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

  FolderSizeCalculator scanner = FolderSizeCalculator(getDesktopDirectory()!);
  late FileSystemNode base;
  List<FileSystemNode> filelist = [];

  GlobalKey key = GlobalKey();

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
            FileSystemWidget(nodes: filelist)),

            Expanded(child: 
 Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                        slices: slices,
                        radius: 150,
                        onPressed: (int index) {
                          sliceClicked(index);
                        },
                        key: key,
                      ),
                    
                    FloatingActionButton(
                        onPressed: () {
                          if (base.parent != null){
                          base = base.parent!;
                          prepareSliceData();
                          }

                        },
                        child: Icon(Icons.add),
                      ),
                  ],
                ),
              
            )
          ]
        ),
      ),
    );
  }

  void sliceClicked(int index){
    base = base.children[index];
    
    prepareSliceData();
  }

  void readyMap() async {
    base = await scanner.mapFileSystem();
    filelist = base.children;

        prepareSliceData();
  }


  Future<void> prepareSliceData() async {

    base.children.sort((a, b) => a.size.compareTo(b.size));


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



