import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:lectura/objects.dart';
import 'package:http/http.dart' as http;
import 'package:lectura/variables.dart';

// Meldet API-Fehler über den gemeinsamen errorNotifier an die angemeldeten Seiten.
/// @brief Stellt API-Fehlermeldungen für die Oberfläche bereit.
class ErrorNotifier with ChangeNotifier {
  String errorMessage = "";

  /// @brief Liest die zuletzt gemeldete Fehlermeldung.
  /// @return Fehlermeldung oder ein leerer String vor dem ersten Fehler.
  String get message => errorMessage;

  /// @brief Speichert einen Fehler und benachrichtigt die registrierten Listener.
  /// @param message Anzuzeigende Fehlermeldung.
  void callError(String message) {
    errorMessage = message;
    notifyListeners();
  }
}

// Lädt den Fragenkatalog; die Seiten verwenden Question-Objekte statt roher JSON-Daten.
/// @brief Ruft den Fragenkatalog über GET /questions ab.
/// @return Future mit den Fragen; bei einem abgefangenen Fehler eine leere Liste.
/// @note Fehler werden über errorNotifier gemeldet.
Future<List<Question>> getQuestions() async {
  final uri = Uri.parse('$baseUrl/questions');

  List<Question> questions = [];
  try {
    // Begrenzt die Wartezeit, damit eine ausbleibende Antwort als Fehler gemeldet wird.
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

// Löst eine Fragen-ID in den Fragetext auf; lädt dafür den ganzen Katalog.
/// @brief Sucht eine Frage im über getQuestions geladenen Katalog.
/// @param questionId ID der gesuchten Frage.
/// @return Future mit der Frage oder null, wenn sie nicht gefunden wurde.
Future<Question?> getQuestionById(String questionId) async {
  final questions = await getQuestions();

  for (final question in questions) {
    if (question.id == questionId) {
      return question;
    }
  }

  return null;
}

// Liefert Vorlagen für die Startauswahl und die Zuordnung gespeicherter Ergebnisse.
/// @brief Ruft die Umfragevorlagen über GET /evaluations ab.
/// @return Future mit den Vorlagen; bei einem abgefangenen Fehler eine leere Liste.
/// @note Fehler werden über errorNotifier gemeldet.
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

// Speichert Name und Fragen-IDs als Vorlage; Antworten werden getrennt gespeichert.
/// @brief Erstellt eine Umfragevorlage über POST /evaluations.
/// @param name Name der neuen Vorlage.
/// @param questionIds IDs der ausgewählten Fragen in ihrer Reihenfolge.
/// @return Future mit der vom Server zurückgegebenen Vorlage.
/// @note API-Fehler werden gemeldet; eine fehlende oder ungültige Vorlage
/// kann anschließend beim Umwandeln der Antwort einen Fehler auslösen.
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

// Lädt gespeicherte Antwortsammlungen für die Übersicht der Auswertungen.
/// @brief Ruft gespeicherte Auswertungen über GET /results ab.
/// @return Future mit den Auswertungen; bei abgefangenen Anfrage- oder JSON-Fehlern leer.
/// @note Fehler beim Umwandeln einzelner Einträge werden an den Aufrufer weitergegeben.
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

// Verknüpft Antworten über evaluationId mit ihrer Vorlage und sendet sie als JSON.
/// @brief Speichert eine Antwortsammlung über POST /results.
/// @param evaluationId ID der zugehörigen Umfragevorlage.
/// @param results Fragen-IDs mit den zugehörigen Bewertungen von 1 bis 5.
/// @return Future mit der vom Server zurückgegebenen Auswertung.
/// @note API-Fehler werden gemeldet; das anschließende Auswerten einer leeren
/// oder ungültigen Serverantwort kann einen weiteren Fehler auslösen.
Future<EvaluationResult> createEvaluationResult(
  String evaluationId,
  Map<String, List<int>> results,
) async {
  http.Response response = http.Response("", 500);
  final uri = Uri.parse('$baseUrl/results');

  try {
    response = await http.post(
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
