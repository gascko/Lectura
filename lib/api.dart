import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lectura/objects.dart';
import 'package:http/http.dart' as http;

// Future<List<Question>> getQuestions() async {
//   final String response = await rootBundle.loadString(
//     'assets/questionsInit.json',
//   );
//   final List<dynamic> jsonList = await json.decode(response);
//   final List<Question> questions = jsonList
//       .map((item) => Question.fromJson(item as Map<String, dynamic>))
//       .toList();
//   return questions;
// }


Future<List<Question>> getQuestions() async {
  final uri = Uri.parse(
    'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev/questions',
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
//   final String response = await rootBundle.loadString(
//     'assets/questionsInit.json',
//   );
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


//  Future<List<Evaluation>> getEvaluations() async {
//    final String response = await rootBundle.loadString('assets/evaluationInit.json');
//    final List<dynamic> jsonList = await json.decode(response);
//    final List<Evaluation> evaluations = jsonList
//        .map((item) => Evaluation.fromJson(item as Map<String, dynamic>))
//        .toList();
//    return evaluations;
//  }


Future<List<Evaluation>> getEvaluations() async {
  final uri = Uri.parse(
    'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev/evaluations',
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      'Evaluationen konnten nicht geladen werden. Status: ${response.statusCode}',
    );
  }

  final List<dynamic> jsonList = jsonDecode(response.body);

  final List<Evaluation> evaluations = jsonList
      .map((item) => Evaluation.fromJson(item as Map<String, dynamic>))
      .toList();

  return evaluations;
}



Future<Evaluation> createEvaluation(
  String name,
  List<String> questionIds,
) async {
  final uri = Uri.parse(
    'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev/evaluations',
  );

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
  final Map<String, dynamic> jsonMap = jsonDecode(response.body);

  return Evaluation.fromJson(jsonMap);
}


// bool createEvaluation(String name, List<String> questionIds) {
//   print("Gespeichert trust");
//   return true;
// }

// Future<List<EvaluationResult>> getEvaluationResults() async {
//   final String response = await rootBundle.loadString(
//     'assets/evaluationResultInit.json',
//   );
//   final List<dynamic> jsonList = await json.decode(response);
//   final List<EvaluationResult> evaluationResults = jsonList
//       .map((item) => EvaluationResult.fromJson(item as Map<String, dynamic>))
//       .toList();
//   return evaluationResults;
// }

Future<List<EvaluationResult>> getEvaluationResults() async {
  final uri = Uri.parse(
    'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev/results',
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      'Auswertungen konnten nicht geladen werden. Status: ${response.statusCode}',
    );
  }

  final List<dynamic> jsonList = jsonDecode(response.body);

  return jsonList
      .map((item) => EvaluationResult.fromJson(item as Map<String, dynamic>))
      .toList();
}



Future<EvaluationResult> createEvaluationResult(
  String evaluationId,
  Map<String, List<int>> results,
) async {
  final uri = Uri.parse(
    'https://r7gfduecni.execute-api.us-east-1.amazonaws.com/dev/results',
  );

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'evaluationId': evaluationId,
      'results': results,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception(
      'Auswertung konnte nicht gespeichert werden. Status: ${response.statusCode}',
    );
  }

  return EvaluationResult.fromJson(
    jsonDecode(response.body) as Map<String, dynamic>,
  );
}
