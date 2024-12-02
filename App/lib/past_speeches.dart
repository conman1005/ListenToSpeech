import 'dart:convert';
import 'dart:io';
import 'package:lab5/main.dart';
import 'package:path_provider/path_provider.dart';
import 'speeches.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MySpeeches());

class MySpeeches extends StatefulWidget {
  const MySpeeches({super.key});
  @override
  State<MySpeeches> createState() => MySpeechesState();
}

class MySpeechesState extends State<MySpeeches> {

   Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/speeches.json');
  }
  
  var testData = "";
  List<Map> data = [];

  String displayText = "";

  // Generate a List of Object Maps from the JSON file
  Future<List<Map>> readJson() async {
    final File file = await _localFile;
    final String jsonString = await file.readAsString();
    testData = jsonString;
    List jsonList = [];
    if (jsonString.contains(", ")) {
      jsonList = jsonString.split(", ");
    } else {
      jsonList.add(jsonString);
    }
    
    List<Map> objectList = [];
    for (var json in jsonList) {
      final Map decoded = await jsonDecode(json);
      objectList.add(decoded);
      debugPrint("JSON: ${decoded['content']}");
      displayText += "Title: ${decoded['title']}\n${decoded['content']}\n\n";
    }
    //var decoded = jsonDecode(json);
    
    //testData = json;
    setState(() {});
    return objectList;
  }

  Future<void> setJson() async {
    data = await readJson();
  }

  @override
  void initState()  {
    super.initState();
    setJson();
  }

  void viewMainPage() {
    //Navigator.of(context).pushNamed("/pastSpeeches");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCounter()),
    );

    //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => new MySpeeches()));
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    /*ThemeData(
      textTheme: GoogleFonts.kalamTextTheme(),
    );*/
    return MaterialApp( // Root widget
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Home Page'),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  const Text('Conner Cullity (100760244)'),
                  const Text('INFT-3101 Section 2'),
                  const Text('Speech Recognition'),
                  const SizedBox(height: 20),
                  Text(testData == "" ? "No memos saved." : "Previous Recordings:\n$displayText" ),
                  FloatingActionButton(
                    onPressed:
                        // If not yet listening for speech start, otherwise stop
                        viewMainPage,
                    tooltip: 'Back to Main Page',
                    child: const Text('Back'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}