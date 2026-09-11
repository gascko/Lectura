import 'package:flutter/material.dart';
import 'package:horizontal_stepper_flutter/horizontal_stepper_flutter.dart';

int currentStep = 0;

class createEvaluationPage extends StatelessWidget {
  createEvaluationPage({super.key});

  final steps = [
    (title: 'Thema', page: topicStep()),
    (title: 'Fragen', page: questionSelectionStep()),
    (title: 'Starten', page: startEvaluationStep()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Neue Evaluation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                creationStepper(steps: steps.map((elefsment) => element.title).toList(), currentStep: currentStep + 1),
                steps[currentStep].page,
                ElevatedButton(onPressed: () {
                  setState(() {});

                }, child: Text("Nächster Schritt"))
              ],
            )
        )
    );
  }
}

class creationStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  const creationStepper({required this.steps, required this.currentStep, super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterHorizontalStepper(steps: steps, radius: 45, currentStep: currentStep, child: [
      Text("1"),
      Text("2"),
      Text("3")
    ]);
  }
}

class topicStep extends StatelessWidget {
  const topicStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Step 1"),
      ],
    );
  }
}

class questionSelectionStep extends StatelessWidget {
  const questionSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Step 2"),
      ],
    );
  }
}

class startEvaluationStep extends StatelessWidget {
  const startEvaluationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Step 3")
      ],
    );
  }
}