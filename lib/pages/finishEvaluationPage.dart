import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinishEvaluationPage extends StatefulWidget {
  const FinishEvaluationPage({super.key});

  @override
  State<FinishEvaluationPage> createState() => FinishEvaluationPageState();
}

class FinishEvaluationPageState extends State<FinishEvaluationPage> {
  int _counter = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_counter <= 0) {
        Navigator.pop(context);
      }
      setState(() {
        _counter--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 200),
            Text("Danke für dein Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Bitte gib das Gerät an die nächste Person weiter."),
            SizedBox(height: 30),
            Text("Nächste Umfrage startet automatisch in ${_counter} Sekunden..."),
          ],
        ),
      ),
      )
    );
  }
}
