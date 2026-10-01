import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lectura/objects.dart';

Future<List<Question>> getQuestions() async {
  final String response = await rootBundle.loadString('assets/questionsInit.json');
  final List<dynamic> jsonList = await json.decode(response);
  final List<Question> questions = jsonList
      .map((item) => Question.fromJson(item as Map<String, dynamic>))
      .toList();
  return questions;
}

Future<Question?> getQuestionById(String questionId) async {
  final String response = await rootBundle.loadString('assets/questionsInit.json');
  final List<dynamic> jsonList = await json.decode(response);
  final List<Question> questions = jsonList
      .map((item) => Question.fromJson(item as Map<String, dynamic>))
      .toList();
  for (int i = 0; i < questions.length; i++) {
    if (questions[i].id == questionId) {
      return questions[i];
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
