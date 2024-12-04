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
import 'package:lab5/home.dart';
import 'package:lab5/settings.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: const Home(),
          routes: <String, WidgetBuilder>{
            "/settings": (BuildContext context) =>
                SettingsPage(themeNotifier: themeNotifier),
            "/main": (BuildContext context) => const MyCounter(),
            "/pastSpeeches": (BuildContext context) => const MySpeeches(),
          },
        );
      },
    );
  }
}

class MyCounter extends StatefulWidget {
  const MyCounter({super.key});
  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
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
    return file.writeAsString(text, mode: FileMode.append);
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  var speeches = [];

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
    if (_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    setState(() {});
  }

  void _startListening() async {
    if (_speechToText.isAvailable) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (_lastWords.isNotEmpty) {
      if (_speechToText.isNotListening) {
        Speeches speech = Speeches(speeches.length, _lastWords[0], _lastWords);
        speeches.add(speech);
        final File testRead = await _localFile;
        final bool jsonExists = await testRead.exists();
        String json = "";
        if (jsonExists) {
          final read = await testRead.readAsString();
          if (read.isEmpty) {
            json = jsonEncode(speech);
          } else {
            json = ", ${jsonEncode(speech)}";
          }
        } else {
          json = jsonEncode(speech);
        }
        writeSpeech(json);
      }
    }
  }

  void viewSpeechesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySpeeches()),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Speech Recognition',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What you said:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                minHeight: 400,
                maxHeight: 400, // Stable height for the box
              ),
              width: double.infinity, // Ensure it takes the full width
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _lastWords.isNotEmpty
                      ? _lastWords // Show the recognized speech
                      : _speechToText.isListening
                          ? 'Listening...'
                          : _speechEnabled
                              ? 'Tap the microphone to start listening...'
                              : 'Speech not available',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                  backgroundColor: Colors.blue,
                  tooltip: 'Listen',
                  child: Icon(
                    _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  onPressed: viewSpeechesPage,
                  backgroundColor: Colors.blue,
                  tooltip: 'View Speeches',
                  child: const Icon(
                    Icons.library_books,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}