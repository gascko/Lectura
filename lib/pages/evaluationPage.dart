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
      floatingActionButton: ElevatedButton(
        onPressed: exitEvaluation,
        child: Icon(Icons.exit_to_app),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 20,
          children: [
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
              ],
            ),
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
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text(
                "Frage ${currentQuestion} von ${widget.evaluation.questions.length}",
              ),
            ],
          ),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: LinearProgressIndicator(value: currentQuestion.toDouble()),
          ),
        ],
      ),
    );
  }
}
