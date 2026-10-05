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

    // widget.evaluationResult.results.forEach((key, values) async {
    //   Question? question = await getQuestionById(key);
     for (final key in widget.evaluationResult.results.keys) {
    Question? question = await getQuestionById(key);
      if (question != null) {
        questions.add(question);
      }
    };
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: loadEvaluationQuestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsetsGeometry.all(10),
            children: [
              Padding(
                padding: EdgeInsetsGeometry.directional(bottom: 12),
                child: Text(
                  widget.evaluation.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              ),Card(
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
              ...snapshot.data!.map(
                (question) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Card(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsetsGeometry.all(10), child:
                          Text(question.text),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.directional(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsGeometry.directional(
                                    end: 30,
                                  ),
                                  child: Text(
                                    "${calculateAverageRatingForQuestion(question.id).toStringAsFixed(2)} / 5",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                StarRating(
                                  allowHalfRating: true,
                                  rating: calculateAverageRatingForQuestion(
                                    question.id,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
