/*
 *  Authours:           Conner Cullity and Jy
 *  Date last Revised:  2024-12-05
 *  Purpose:            This is an app that is meant to Listen to the User's Speech and save Transcripts. This app also utilizes ChatGPT to analyse the Speech.
 */


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:lab5/past_speeches.dart';


/// Initialize View Speech Page
class MySpeech extends StatefulWidget {
  const MySpeech({super.key});

  @override
  State<MySpeech> createState() => MySpeechState();
}

class MySpeechState extends State<MySpeech> {
  String formattedResponse = '';
  bool isLoading = false;

  /// Analyse speech with ChatGPT
  Future<void> sendToChatGPT(String text) async {
    if (text.isEmpty) {
      setState(() {
        formattedResponse = "Error: No text provided for processing.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        formattedResponse = "Error: API key not found in .env file.";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };
    
    final body = jsonEncode({
      "model": "gpt-4o",
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful assistant that organizes text into clear, readable documents."
        },
        {
          "role": "user",
          "content": "Organize the following text into a readable document with a title, bullet points, and sections:\n\n$text"
        }
      ],
      "temperature": 0.7,
    });

    try {
      final response = await http.post(
        url, 
        headers: headers, 
        body: body
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String aiResponse = data['choices'][0]['message']['content']?.trim() ?? '';
        
        setState(() {
          formattedResponse = aiResponse;
          isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          formattedResponse = "Error: ${errorData['error']['message'] ?? 'Failed to process the request.'}";
          isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        formattedResponse = "Error: Request timed out. Please try again.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        formattedResponse = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  /// Navigate User back to Speeches List Page
  void viewSpeechesPage() {
    Navigator.pop(context);  // Changed from push to pop
  }

  /// Build View Speeches Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Removed MaterialApp wrapper
      appBar: AppBar(
        title: const Text('View Speech'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing your speech...'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Speech AI Processor',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            formattedResponse.isEmpty
                                ? selectedContent
                                : formattedResponse,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await sendToChatGPT(selectedContent);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Process with AI',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: viewSpeechesPage,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back to Speeches Page',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}