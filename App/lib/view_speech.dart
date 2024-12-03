import 'dart:convert';
import 'dart:io';
import 'package:lab5/main.dart';
import 'package:path_provider/path_provider.dart';
import 'speeches.dart';
import 'package:lab5/past_speeches.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MySpeech());

class MySpeech extends StatefulWidget {
  const MySpeech({super.key});
  @override
  State<MySpeech> createState() => MySpeechState();
}

class MySpeechState extends State<MySpeech> {


  void viewSpeechesPage() {
    //Navigator.of(context).pushNamed("/pastSpeeches");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySpeeches()),
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
                  Text('Title: $selectedTitle', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),),
                  const SizedBox(height: 20),
                  Text(selectedContent),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed:
                        // If not yet listening for speech start, otherwise stop
                        viewSpeechesPage,
                    tooltip: 'Back to Speeches Page',
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