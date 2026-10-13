import 'package:flutter/material.dart';
import 'package:lectura/api.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'package:lectura/pages/evaluationResultPage.dart';
import 'package:intl/intl.dart';
import 'package:lectura/variables.dart';

class SelectResultPage extends StatefulWidget {
  const SelectResultPage({super.key});

  @override
  State<SelectResultPage> createState() => SelectResultPageState();
}

class SelectResultPageState extends State<SelectResultPage> {
  List<EvaluationResult> targetResults = [];
  bool search = false;

  @override
  void initState() {
    super.initState();

    errorNotifier.addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ein Fehler ist aufgetreten. ${errorNotifier.errorMessage}"),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LecturaApp()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Auswertung",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([getEvaluationResults(), getEvaluations()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final evaluationResults = snapshot.data![0] as List<EvaluationResult>;
          final evaluations = snapshot.data![1] as List<Evaluation>;

          if (!search) {
            targetResults = evaluationResults.toList();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  "Vorhandene Auswertungen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Wähleeine Auswertung aus, um sie anzusehen.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Auswertungen durchsuchen",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(width: 1.5),
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      if (text.isNotEmpty) {
                        search = true;
                        targetResults = evaluationResults
                            .where(
                              (result) {
                                final matchingEvaluations = evaluations.where(
                                  (evaluation) =>
                                      evaluation.id == result.evaluationId,
                                );

                                if (matchingEvaluations.isEmpty) {
                                  return false;
                                }

                                return matchingEvaluations.first.name.contains(
                                  text,
                                );
                              },
                            )
                            .toList();
                      } else {
                        search = false;
                      }
                    });
                  },
                ),
              ),

              ...targetResults.map((result) {
                final matchingEvaluations = evaluations.where(
                  (evaluation) => evaluation.id == result.evaluationId,
                );

                if (matchingEvaluations.isEmpty) {
                  return const SizedBox.shrink();
                }

                final evaluation = matchingEvaluations.first;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Card(
                    child: ListTile(
                      trailing: const Icon(Icons.chevron_right),
                      title: Text(evaluation.name, softWrap: true),
                      subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(result.dateOfEvaluation),),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EvaluationResultPage(
                              evaluation: evaluation,
                              evaluationResult: result,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
