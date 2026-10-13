import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:lectura/objects.dart';
import 'package:http/http.dart' as http;
import 'package:lectura/variables.dart';

class ErrorNotifier with ChangeNotifier {
  String errorMessage = "";

  String get message => errorMessage;

  void callError(String message) {
    errorMessage = message;
    notifyListeners();
  }
}

Future<List<Question>> getQuestions() async {
  final uri = Uri.parse('$baseUrl/questions');

  List<Question> questions = [];
  try {
    final response = await http.get(uri).timeout(
        Duration(seconds: timeoutDuration));

    if (response.statusCode != 200) {
      throw Exception(
        'Fragen konnten nicht geladen werden. Status: ${response.statusCode}',);
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    questions = jsonList
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    errorNotifier.callError(e.toString());
  }
  return questions;
}

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
final uri = Uri.parse('$baseUrl/evaluations');

  List<Evaluation> evaluations = [];
  try {
    final response = await http.get(uri).timeout(
        Duration(seconds: timeoutDuration));
    ;

    if (response.statusCode != 200) {
      throw Exception(
        'Evaluationen konnten nicht geladen werden. Status: ${response
            .statusCode}',
      );
    }

    final List<dynamic> jsonList = jsonDecode(response.body);

    evaluations = jsonList
        .map((item) => Evaluation.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch(e) {
    errorNotifier.callError(e.toString());
  }
  return evaluations;
}

Future<Evaluation> createEvaluation(
  String name,
  List<String> questionIds,
) async {
  final uri = Uri.parse('$baseUrl/evaluations');
  Map<String, dynamic> jsonMap = {};
  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'questionIds': questionIds}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Evaluation konnte nicht gespeichert werden. Status: ${response.statusCode}',
      );
    }
    jsonMap = jsonDecode(response.body);
  } catch (e) {
    errorNotifier.callError(e.toString());
  }
  return Evaluation.fromJson(jsonMap);
}

Future<List<EvaluationResult>> getEvaluationResults() async {
  final uri = Uri.parse('$baseUrl/results');
  List<dynamic> jsonList = [];

  try {
    final response = await http
        .get(uri)
        .timeout(Duration(seconds: timeoutDuration));

    if (response.statusCode != 200) {
      throw Exception(
        'Auswertungen konnten nicht geladen werden. Status: ${response.statusCode}',
      );
    }

    jsonList = jsonDecode(response.body);
  } catch (e) {
    errorNotifier.callError(e.toString());
  }
  return jsonList
      .map((item) => EvaluationResult.fromJson(item as Map<String, dynamic>))
      .toList();
}

Future<EvaluationResult> createEvaluationResult(
  String evaluationId,
  Map<String, List<int>> results,
) async {
  http.Response response = http.Response("", 500);
  final uri = Uri.parse('$baseUrl/results');

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'evaluationId': evaluationId, 'results': results}),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Auswertung konnte nicht gespeichert werden. Status: ${response.statusCode}',
      );
    }
  } catch (e) {
    errorNotifier.callError(e.toString());
  }

  return EvaluationResult.fromJson(
    jsonDecode(response.body) as Map<String, dynamic>,
  );
}

/* ####################### Debug Funktionen mit lokalen JSON Dateien ######################## */

/*
import 'package:flutter/services.dart';

Future<List<Question>> getQuestions() async {
 final String response = await rootBundle.loadString(
   'assets/questionsInit.json',
 );
 final List<dynamic> jsonList = await json.decode(response);
 final List<Question> questions = jsonList
     .map((item) => Question.fromJson(item as Map<String, dynamic>))
     .toList();
 return questions;
}
bool createEvaluation(String name, List<String> questionIds) {
 print("Gespeichert trust");
 return true;
}

Future<List<EvaluationResult>> getEvaluationResults() async {
 final String response = await rootBundle.loadString(
   'assets/evaluationResultInit.json',
 );
 final List<dynamic> jsonList = await json.decode(response);
 final List<EvaluationResult> evaluationResults = jsonList
     .map((item) => EvaluationResult.fromJson(item as Map<String, dynamic>))
     .toList();
 return evaluationResults;
}

Future<List<Evaluation>> getEvaluations() async {
  final String response = await rootBundle.loadString(
    'assets/evaluationInit.json',
  );
  final List<dynamic> jsonList = await json.decode(response);
  final List<Evaluation> evaluations = jsonList
      .map((item) => Evaluation.fromJson(item as Map<String, dynamic>))
      .toList();
  return evaluations;
}

Future<Question?> getQuestionById(String questionId) async {
  final String response = await rootBundle.loadString(
    'assets/questionsInit.json',
  );
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
*/
