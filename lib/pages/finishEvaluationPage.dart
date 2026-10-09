import 'dart:async';
import 'package:flutter/material.dart';

class FinishEvaluationPage extends StatefulWidget {
  const FinishEvaluationPage({super.key});

  @override
  State<FinishEvaluationPage> createState() => FinishEvaluationPageState();
}

class FinishEvaluationPageState extends State<FinishEvaluationPage> {
  int counter = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (counter <= 0) {
        Navigator.pop(context);
        return;
      }
      setState(() {
        counter--;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
      canPop: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 200,
                    ),
                    const Text(
                      "Danke für dein Feedback",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "Bitte gib das Gerät an die nächste Person weiter.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Nächste Umfrage startet automatisch in ${counter} Sekunden...",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }
}
