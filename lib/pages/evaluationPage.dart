import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
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
  List<Result> results = [];
  late Future<List<Question>> questionsFuture;

  @override
  void initState() {
    super.initState();
    questionsFuture = getQuestions();
  }

  Future<bool?> exitDialog() async {
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
                final bool shouldPop = await exitDialog() ?? false;
                if (context.mounted && shouldPop) {
                  Navigator.pop(context);
                }
              },
              child: IconButton(
                onPressed: exitDialog,
                icon: Icon(Icons.exit_to_app),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Text(
                "Frage ${currentQuestion} von ${widget.evaluation.questionIds.length}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: LinearProgressIndicator(
                  value:
                      currentQuestion *
                      (1 / widget.evaluation.questionIds.length),
                  minHeight: 10,
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.onPrimary,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.directional(bottom: 20),
                        child: Text(
                          snapshot.data!
                              .where(
                                (question) =>
                                    question.id ==
                                    widget
                                        .evaluation
                                        .questionIds[currentQuestion - 1],
                              )
                              .first
                              .text,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.directional(bottom: 20),
                        child: Wrap(
                          spacing: 5.0,
                          children: List<Widget>.generate(5, (int index) {
                            return ChoiceChip(
                              showCheckmark: false,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(100),
                                ),
                              ),
                              label: Text(
                                emojis[index],
                                style: TextStyle(fontSize: 30),
                              ),
                              selected: selectedValue == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedValue = selected ? index : null;
                                  results.add(
                                    Result(
                                      widget
                                          .evaluation
                                          .questionIds[currentQuestion - 1],
                                      selectedValue!,
                                    ),
                                  );
                                  if (currentQuestion <
                                      widget.evaluation.questionIds.length) {
                                    currentQuestion += 1;
                                    selectedValue = null;
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FinishEvaluationPage(),
                                      ),
                                    );
                                    currentQuestion = 1;
                                    selectedValue = null;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
