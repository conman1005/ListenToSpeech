import 'dart:convert';
import 'dart:io';
import 'package:lab5/main.dart';
import 'package:lab5/view_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lab5/speeches.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MySpeeches());

class MySpeeches extends StatefulWidget {
  const MySpeeches({super.key});
  @override
  State<MySpeeches> createState() => MySpeechesState();
}

// These Strings will be used in the view_speeches page to display content
String selectedTitle = "";
String selectedContent = "";

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

  Column contentColumn = const Column();

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

    List<String> titles = [];
    List<String> contents = [];
    
    for (var json in jsonList) {
      final Map decoded = await jsonDecode(json);
      objectList.add(decoded);
      debugPrint("JSON: ${decoded['content']}");
      displayText += "Title: ${decoded['title']}\n${decoded['content']}\n\n";
      
      titles.add(decoded['title']);
      contents.add(decoded['content']);
    }

    
    Column column = Column(
      children: [
        for (var object in objectList) Column(
          children: [
            InkWell(child: Text("Title: ${object['title']}", style: const TextStyle(color: Color.fromARGB(255, 0, 95, 204), fontSize: 16)), onTap: () => {
              selectedTitle = object['title'],
              selectedContent = object['content'],
              viewSpeechPage,
            }),
            Text(object['content'].length <= 20 ? object['content'] : "${object['content'].substring(0, 20)}..."),
            FloatingActionButton(
                    onPressed:
                        viewSpeechPage,
                    tooltip: 'View Whole Speech',
                    child: const Text('View'),
                  ),
            const SizedBox(height: 20),
          ]
        ),
      ]
    );

    contentColumn = column;

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

  
  void viewSpeechPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySpeech()),
    );

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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Conner Cullity (100760244)'),
                    const Text('INFT-3101 Section 2'),
                    const Text('Speech Recognition'),
                    const SizedBox(height: 20),
                    Text(testData == "" ? "No memos saved." : "Previous Recordings:\n" ),
                    contentColumn,
                    FloatingActionButton(
                      onPressed:
                          viewMainPage,
                      tooltip: 'Back to Main Page',
                      child: const Text('Back'),
                    ),
                  ],
                )
              );
            },
          ),
        ),
      ),
    );
  }
}