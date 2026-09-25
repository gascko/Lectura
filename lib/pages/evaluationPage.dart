import 'package:flutter/material.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'finishEvaluationPage.dart';

class EvaluationPage extends StatefulWidget {
  final Evaluation evaluation;

  const EvaluationPage({super.key, required this.evaluation});

  @override
  State<EvaluationPage> createState() => evaluationPageState();
}

class evaluationPageState extends State<EvaluationPage> {
  evaluationPageState();

  int? selectedValue;
  int currentQuestion = 1;
  List<String> emojis = ["🤯", "😕", "🫤", "😊", "🤩"];

  Future<bool?> _showBackDialog() async {
    await SoLoud.instance.init();
    final sound = await SoLoud.instance.loadAsset('assets/warning.mp3');
    SoLoud.instance.play(sound);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umfrage beenden?'),
          content: const Text('Möchtest du die Umfrage wirklich beenden?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nein'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ja'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LecturaApp()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, Object? result) async {
                if (didPop) {
                  return;
                }
                final bool shouldPop = await _showBackDialog() ?? false;
                if (context.mounted && shouldPop) {
                  Navigator.pop(context);
                }
              },
              child: ElevatedButton(
                onPressed: _showBackDialog,
                child: Icon(Icons.exit_to_app),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            "Frage ${currentQuestion} von ${widget.evaluation.questionIds.length}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: LinearProgressIndicator(
              value: currentQuestion * (1 / widget.evaluation.questionIds.length),
              minHeight: 15,
              borderRadius: BorderRadiusGeometry.circular(20),
            ),
          ),
          SizedBox(height: 20),
          Text(
            widget.evaluation.questions[currentQuestion - 1],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 50),
          Wrap(
            spacing: 5.0,
            children: List<Widget>.generate(5, (int index) {
              return ChoiceChip(
                showCheckmark: false,
                label: Text(emojis[index], style: TextStyle(fontSize: 30)),
                selected: selectedValue == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedValue = selected ? index : null;
                    widget.evaluation.results.add(index);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          children: [
            if (currentQuestion > 1)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestion -= 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text("Zurück"),
                ),
              ),
            if (currentQuestion == widget.evaluation.questions.length)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinishEvaluationPage()),
                      );
                      currentQuestion = 1;
                      selectedValue = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text("Umfrage abschließen"),
                ),
              ),
            if (currentQuestion < widget.evaluation.questions.length)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestion += 1;
                      selectedValue = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text("Nächste Frage"),
                ),
              ),
          ],
        ),
      ],
    );
  }
}