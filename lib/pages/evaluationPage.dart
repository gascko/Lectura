import 'package:flutter/material.dart';
import 'package:lectura/objects.dart';

class EvaluationPage extends StatefulWidget {
  final Evaluation evaluation;

  const EvaluationPage({super.key, required this.evaluation});

  @override
  State<EvaluationPage> createState() => evaluationPageState();
}

class evaluationPageState extends State<EvaluationPage> {
  evaluationPageState();

  int currentQuestion = 1;

  void exitEvaluation() {
    print("Ich muss raus");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: ElevatedButton(
              onPressed: exitEvaluation,
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            "Frage ${currentQuestion} von ${widget.evaluation.questions.length}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: LinearProgressIndicator(
              value: currentQuestion.toDouble(),
              minHeight: 15,
              borderRadius: BorderRadiusGeometry.circular(20),
            ),
          ),
          SizedBox(height: 20),
          Text(
            widget.evaluation.questions[currentQuestion],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Row(children: [
              Text("🤯", style: TextStyle(fontSize: 60)),
              Text("😕", style: TextStyle(fontSize: 60)),
              Text("🫤", style: TextStyle(fontSize: 60)),
              Text("😊", style: TextStyle(fontSize: 60)),
              Text("🤩", style: TextStyle(fontSize: 60))
            ]
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text("Weiter"),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text("Weiter"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
