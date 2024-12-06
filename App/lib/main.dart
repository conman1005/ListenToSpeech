/*
 *  Authours:           Conner Cullity and Jy
 *  Date last Revised:  2024-12-05
 *  Purpose:            This is an app that is meant to Listen to the User's Speech and save Transcripts. This app also utilizes ChatGPT to analyse the Speech.
 */

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
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Global variable to store the selected speech recognition language.
// Default is "en_US".
String selectedLanguage = "en_US";

// Initialize Program and load .env variables
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// Initialize app with Themes and Routes
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
            "/main": (BuildContext context) => const MyListener(),
            "/pastSpeeches": (BuildContext context) => const MySpeeches(),
          },
        );
      },
    );
  }
}

/// Create Listener State
class MyListener extends StatefulWidget {
  const MyListener({super.key});
  @override
  State<MyListener> createState() => _MyListenerState();
}

/// Listener Page
class _MyListenerState extends State<MyListener> {
  /// Get App's directory on device
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Get speeches.json from Device
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/speeches.json');
  }

  /// Write json to speeches.json
  Future<File> writeSpeech(String text) async {
    final file = await _localFile;
    return file.writeAsString(text, mode: FileMode.append);
  }

  // Initialize Speech Variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  var speeches = [];

  /// Initialize SpeechToText once Microphone Permission is Granted
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

  /// Listen to User's Speech and write it to _lastWords
  void _startListening() async {
    if (_speechToText.isAvailable) {
      // Use the selectedLanguage global variable to set the locale.
      await _speechToText.listen(onResult: _onSpeechResult, localeId: selectedLanguage);
      setState(() {});
    }
  }

  /// Stop listening to Speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// On end of listening create JSON string of speech then write to speeches.json
  void _onSpeechResult(SpeechRecognitionResult result) async {
    // Get recognized speech
    setState(() {
      _lastWords = result.recognizedWords;
    });
    // Check if there are any recorded words and make sure it is not listening
    if (_lastWords.isNotEmpty) {
      if (_speechToText.isNotListening) {
        // Create Speeches object
        Speeches speech = Speeches(speeches.length, _lastWords[0], _lastWords);
        // add object to speeches List
        speeches.add(speech);
        // Check speeches.json before adding to file
        final File testRead = await _localFile;
        final bool jsonExists = await testRead.exists();
        String json = "";
        // Read speeches.json if file exists
        if (jsonExists) {
          final read = await testRead.readAsString();

          // add json string to speeches.json without edits if file is empty
          if (read.isEmpty) {
            json = jsonEncode(speech);

          // Otherwise add a comma before the json string
          } else {
            json = ", ${jsonEncode(speech)}";
          }
        // add json string to speeches.json without edits if file doesn't exist
        } else {
          json = jsonEncode(speech);
        }
        // append json string to speeches.json
        writeSpeech(json);
      }
    }
  }

  /// Navigates User to Speeches Page
  void viewSpeechesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySpeeches()),
    );
    setState(() {});
  }

  /// Initialize State and Initialize ListenToSpeech
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Build Listener Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(       
        elevation: 0,
        title: const Text(
          'Speech Recognition',
          style: TextStyle(            
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
