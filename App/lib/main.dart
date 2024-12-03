// Code taken from https://docs.flutter.dev/get-started/fundamentals/widgets

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lab5/speeches.dart';
import 'package:lab5/past_speeches.dart';
import 'package:system_theme/system_theme.dart';

//import 'google_fonts';


// Speech Recognition code from https://pub.dev/packages/speech_to_text

void main() => runApp(MaterialApp(
  home: const MyCounter(),
  routes: <String, WidgetBuilder>{
    "/pastSpeeches": (BuildContext context)=> const MySpeeches()
  }
));

class MyCounter extends StatefulWidget {
  const MyCounter({super.key});
  @override
  State<MyCounter> createState() => _MyCounterState();
}

// Moved Speeches class to speeches.dart
/*class Speeches {
  int id;
  String title;
  String content;

  Speeches(this.id, this.title, this.content);

    Map toJson() => {
      'id': id,
      'title': title,
      'content': content
    };
  }*/

class _MyCounterState extends State<MyCounter> {
  //const _MyCounterState({super.key});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/speeches.json');
  }

  Future<File> writeSpeech(String text) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(text, mode: FileMode.append);
  }


  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  var speeches = [];


  /// This has to happen only once per app
  void _initSpeech() async {
    await SystemTheme.accentColor.load();
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        _speechEnabled = await _speechToText.initialize();
      }
    } else {
      _speechEnabled = await _speechToText.initialize();
    }
    // This is for when _speechEnabled is set to true before running program, this will override the permission requirements.
    if (_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (_speechToText.isAvailable) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    }
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (_lastWords.isNotEmpty) {
      // Only write speech when listening has stopped
      if (_speechToText.isNotListening) {
        Speeches speech = Speeches(speeches.length, _lastWords[0], _lastWords);
        speeches.add(speech);
        final File testRead = await _localFile;
        final bool jsonExists = await testRead.exists();
        String json = "";
        // chech if JSON file exists
        if (jsonExists) {
          final read = await testRead.readAsString();
          // if empty write with starting notation
          if (read.isEmpty) {
            json = jsonEncode(speech);
          // otherwise end with comma
          } else {
            json = ", ${jsonEncode(speech)}";
          }
        // write with starting notation if file doesn't exist.
        } else {
          json = jsonEncode(speech);
        }
        //String json = jsonEncode(speech);
        writeSpeech(json);
        //debugPrint("JSON: " + await testRead.readAsString());
      }
    }
  }

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
  void initState() {
    super.initState();
    _initSpeech();
  }

  int count = 0;

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
                  const Text("What you Said:"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      // If listening is active show the recognized words
                      _speechToText.isListening
                          ? 'Listening...'
                          // If listening isn't active but could be tell the user
                          // how to start it, otherwise indicate that speech
                          // recognition is not yet ready or not supported on
                          // the target device
                          : _speechEnabled
                              ? 'Tap the microphone to start listening...'
                              : 'Speech not available',
                    ),
                  ),
                  Text('Last Speech: $_lastWords'),
                  FloatingActionButton(
                    onPressed:
                        // If not yet listening for speech start, otherwise stop
                        _speechToText.isNotListening ? _startListening : _stopListening,
                    tooltip: 'Listen',
                    child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                  ),
                  FloatingActionButton(
                    onPressed:
                        // If not yet listening for speech start, otherwise stop
                        viewSpeechesPage,
                    tooltip: 'View Speeches',
                    child: const Text('View Speeches'),
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