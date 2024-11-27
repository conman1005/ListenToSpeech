// Code taken from https://docs.flutter.dev/get-started/fundamentals/widgets

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'google_fonts';

void main() => runApp(const MyCounter());

class MyCounter extends StatefulWidget {
  const MyCounter({super.key});
  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  //const _MyCounterState({super.key});

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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        count++;
                        print('Click! $count');
                      });
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          count++;
                          print('Click! $count');
                        });
                      },
                      child: Text('A button: $count'),
                    ),
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