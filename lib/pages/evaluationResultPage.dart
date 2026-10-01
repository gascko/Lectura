import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:lectura/api.dart';
import 'package:lectura/main.dart';
import 'package:lectura/objects.dart';
import 'package:intl/intl.dart';

class EvaluationResultPage extends StatefulWidget {
  final EvaluationResult evaluationResult;
  final Evaluation evaluation;

  const EvaluationResultPage({
    super.key,
    required this.evaluation,
    required this.evaluationResult,
  });

  @override
  State<EvaluationResultPage> createState() => EvaluationResultPageState();
}

class EvaluationResultPageState extends State<EvaluationResultPage> {
  double averageRating = 0;
  int totalAnswers = 0;

  @override
  void initState() {
    super.initState();
    calculateTotalAnswers();
    calculateAverageRating();
  }

  Future<List<Question>> loadEvaluationQuestions() async {
    List<Question> questions = [];

    widget.evaluationResult.results.forEach((key, values) async {
      Question? question = await getQuestionById(key);
      if (question != null) {
        questions.add(question);
      }
    });
    return questions;
  }

  void calculateAverageRating() {
    if (totalAnswers > 0) {
      widget.evaluationResult.results.forEach((key, values) {
        for (var result in values) {
          averageRating += result;
        }
      });
      averageRating = averageRating / totalAnswers;
      }
  }

  void calculateTotalAnswers() {
    widget.evaluationResult.results.forEach((key, values) {
      totalAnswers += values.length;
    });
  }

  double calculateAverageRatingForQuestion(String questionId) {
    double average = 0.0;

    for (int value in widget.evaluationResult.results[questionId]!) {
      average += value;
    }
    return average / widget.evaluationResult.results[questionId]!.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LecturaApp()),
                  (route) => false,
            );
          },
        ),
        title: Container(
          padding: EdgeInsets.all(20),
          child: const Text(
            'Auswertung',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: loadEvaluationQuestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 12),
                    child: Text(
                      widget.evaluation.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.directional(bottom: 12),
                    child: Text(
                      DateFormat.yMMMEd().format(
                        widget.evaluationResult.dateOfEvaluation,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Gesamtbewertung",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (totalAnswers > 0)
                            Padding(
                              padding: EdgeInsetsGeometry.all(10),
                              child: Text(
                                "${averageRating.toStringAsFixed(2)} / 5",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            if (totalAnswers > 0)
                              StarRating(
                              allowHalfRating: true,
                              rating: averageRating,
                            ),
                            Text("${totalAnswers} Antworten"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        return Card(
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsGeometry.directional(
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsGeometry.directional(
                                          end: 20,
                                        ),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(snapshot.data![index].text),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.directional(
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsGeometry.directional(
                                          end: 30,
                                        ),
                                        child: Text(
                                          "${calculateAverageRatingForQuestion(snapshot.data![index].id).toStringAsFixed(2)} / 5",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      StarRating(
                                        allowHalfRating: true,
                                        rating:
                                            calculateAverageRatingForQuestion(
                                              snapshot.data![index].id,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
