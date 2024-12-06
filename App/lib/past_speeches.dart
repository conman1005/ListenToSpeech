/*
 *  Authours:           Conner Cullity and Jy
 *  Date last Revised:  2024-12-05
 *  Purpose:            This is an app that is meant to Listen to the User's Speech and save Transcripts. This app also utilizes ChatGPT to analyse the Speech.
 */


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lab5/main.dart';
import 'package:lab5/view_speech.dart';

void main() => runApp(const MySpeeches());

class MySpeeches extends StatefulWidget {
  const MySpeeches({super.key});

  @override
  State<MySpeeches> createState() => MySpeechesState();
}

String selectedTitle = "";
String selectedContent = "";

class MySpeechesState extends State<MySpeeches> {
  /// Get App directory from Device
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// speeches.json
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/speeches.json');
  }

  /// Tile Colours
  List<Map<String, dynamic>> data = [];
  final List<Color> cardColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.yellow.shade100,
  ];

  /// Read speeches.json.<br/>Returns a List of Maps representing Speeches from speeches.json.
  Future<List<Map<String, dynamic>>> readJson() async {
    final File file = await _localFile;
    if (!await file.exists()) return [];

    final String jsonString = await file.readAsString();
    if (jsonString.isEmpty) return [];

    /*List<String> titles = [];
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
              viewSpeechPage(),
            }),
            Text(object['content'].length <= 20 ? object['content'] : "${object['content'].substring(0, 20)}..."),
            FloatingActionButton(
                    onPressed: () => {
                      selectedTitle = object['title'],
                      selectedContent = object['content'],
                      viewSpeechPage(),
                    },
                    tooltip: 'View Whole Speech',
                    child: const Text('View'),
                  ),
            const SizedBox(height: 20),
          ]
        ),
      ]
    );

    contentColumn = column;*/

    //var decoded = jsonDecode(json);
    
    //testData = json;
    //setState(() {});
    //return objectList;

    // Decode speehces.json and return a List of Maps
    return (jsonDecode('[$jsonString]') as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Read speeches.json and add speeches list to the screen
  Future<void> setJson() async {
    data = await readJson();
    setState(() {});
  }

  /// Initialize State and set up json file
  @override
  void initState() {
    super.initState();
    setJson();
  }

  /// Navigate user to the Main Page
  void viewMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyListener()),
    );
  }

  /// Navigate user to the View Speech page
  void viewSpeechPage(Map<String, dynamic> speech) {
    setState(() {
      selectedTitle = speech['title'] ?? 'Untitled';
      selectedContent = speech['content'] ?? 'No content available.';
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySpeech()),
    );
  }

  /// Build past speeches page
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Library',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: data.isEmpty
              ? const Center(
                  child: Text(
                    'No recordings available.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two cards per row
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final speech = data[index];
                    final colorIndex = index % cardColors.length;
                    return GestureDetector(
                      onTap: () => viewSpeechPage(speech),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColors[colorIndex],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              speech['title'] ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              speech['content'] != null &&
                                      speech['content']!.length > 50
                                  ? '${speech['content']?.substring(0, 50)}...'
                                  : speech['content'] ?? 'No content available.',
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: viewMainPage,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.home, color: Colors.white),
        ),
      ),
    );
  }
}
