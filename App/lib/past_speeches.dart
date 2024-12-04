import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lab5/main.dart';
import 'package:lab5/view_speech.dart';
import 'package:lab5/speeches.dart';

void main() => runApp(const MySpeeches());

class MySpeeches extends StatefulWidget {
  const MySpeeches({super.key});

  @override
  State<MySpeeches> createState() => MySpeechesState();
}

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

  List<Map<String, dynamic>> data = [];
  final List<Color> cardColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.yellow.shade100,
  ];

  Future<List<Map<String, dynamic>>> readJson() async {
    final File file = await _localFile;
    if (!await file.exists()) return [];

    final String jsonString = await file.readAsString();
    if (jsonString.isEmpty) return [];

    return (jsonDecode('[$jsonString]') as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<void> setJson() async {
    data = await readJson();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setJson();
  }

  void viewMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCounter()),
    );
  }

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
