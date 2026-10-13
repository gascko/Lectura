import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lectura/api.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'finishEvaluationPage.dart';
import 'evaluationResultPage.dart';

class EvaluationPage extends StatefulWidget {
  final Evaluation evaluation;

  const EvaluationPage({super.key, required this.evaluation});

  @override
  State<EvaluationPage> createState() => EvaluationPageState();
}

class EvaluationPageState extends State<EvaluationPage> {
  EvaluationPageState();

  int? selectedValue;
  int currentQuestion = 1;
  List<String> emojis = ["🤯", "😕", "🫤", "😊", "🤩"];
  Map<String, List<int>> results = {};
  late Future<List<Question>> questionsFuture;

  @override
  void initState() {
    super.initState();
    questionsFuture = getQuestions();
  }

  final player = AudioPlayer();

  Future<void> playWarningSound() async {
    await player.setAsset('assets/warning.mp3');
    await player.play();
  }

  Future<bool?> exitDialog() {
    playWarningSound();
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umfrage beenden?'),
          content: const Text(
            'Möchtest du die Umfrage wirklich beenden?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Beenden'),
              onPressed: () {
                EvaluationResult result = EvaluationResult(
                  widget.evaluation.id,
                  DateTime.now(),
                  results,
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => EvaluationResultPage(
                      evaluation: widget.evaluation,
                      evaluationResult: result,
                    ),
                  ),
                  (route) => false,
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
      resizeToAvoidBottomInset: false,
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
          return ListView(
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
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Column(
                    spacing: 30,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: List<Widget>.generate(5, (int index) {
                            return ChoiceChip(
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(100),
                                ),
                              ),
                              label: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  height: MediaQuery.of(context).size.width * 0.2,
                                  child: Center(child: Text(
                                emojis[index],
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.1,
                                ))),
                              ),
                              selected: selectedValue == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedValue = selected ? index : null;
                                  results
                                      .putIfAbsent(
                                        widget
                                            .evaluation
                                            .questionIds[currentQuestion - 1],
                                        () => [],
                                      )
                                      .add(selectedValue! + 1);
                                });
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
