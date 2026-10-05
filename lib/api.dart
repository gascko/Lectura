import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lectura/objects.dart';
import 'package:http/http.dart' as http;


// erstmal altcode für hardcoded datei behalten für tests und so




// Future<List<Question>> getQuestions() async {
//   final String response = await rootBundle.loadString('assets/questionsInit.json');
//   final List<dynamic> jsonList = await json.decode(response);
//   final List<Question> questions = jsonList
//       .map((item) => Question.fromJson(item as Map<String, dynamic>))
//       .toList();
//   return questions;
// }

Future<List<Question>> getQuestions() async {
  final uri = Uri.parse(
    'https://mhod7qpeg0.execute-api.us-east-1.amazonaws.com/dev/questions',
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      'Fragen konnten nicht geladen werden. Status: ${response.statusCode}',
    );
  }

  final List<dynamic> jsonList = jsonDecode(response.body);
  final List<Question> questions = jsonList
      .map((item) => Question.fromJson(item as Map<String, dynamic>))
      .toList();

  return questions;
}

// Future<Question?> getQuestionById(String questionId) async {
//   final String response = await rootBundle.loadString('assets/questionsInit.json');
//   final List<dynamic> jsonList = await json.decode(response);
//   final List<Question> questions = jsonList
//       .map((item) => Question.fromJson(item as Map<String, dynamic>))
//       .toList();
//   for (int i = 0; i < questions.length; i++) {
//     if (questions[i].id == questionId) {
//       return questions[i];
//     }
//   }
//   return null;
// }

Future<Question?> getQuestionById(String questionId) async {
  final questions = await getQuestions();

  for (final question in questions) {
    if (question.id == questionId) {
      return question;
    }
  }

  return null;
}

Future<List<Evaluation>> getEvaluations() async {
  final String response = await rootBundle.loadString('assets/evaluationInit.json');
  final List<dynamic> jsonList = await json.decode(response);
  final List<Evaluation> evaluations = jsonList
      .map((item) => Evaluation.fromJson(item as Map<String, dynamic>))
      .toList();
  return evaluations;
}

Future<List<EvaluationResult>> getEvaluationResults() async {
  final String response = await rootBundle.loadString('assets/evaluationResultInit.json');
  final List<dynamic> jsonList = await json.decode(response);
  final List<EvaluationResult> evaluationResults = jsonList
      .map((item) => EvaluationResult.fromJson(item as Map<String, dynamic>))
      .toList();
  return evaluationResults;
}
