class Evaluation {
  final String id;
  final String name;
  final DateTime creationDate;
  final List<String> questionIds;

  Evaluation(this.id, this.name, this.creationDate, this.questionIds);

  Evaluation.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      creationDate = DateTime.parse(json['creationDate'] as String),
      questionIds = List<String>.from(json['questionIds']);
}

class EvaluationResult {
  final String evaluationId;
  final DateTime dateOfEvaluation;
  final Map<String, List<int>> results;

  EvaluationResult(this.evaluationId, this.dateOfEvaluation, this.results);

//   EvaluationResult.fromJson(Map<String, dynamic> json)
//     : evaluationId = json['askedQuestionId'] as String,
//       dateOfEvaluation = json['dateOfEvaluation'] as DateTime,
//       results = (json['results'] as Map<String, dynamic>)
//           .map((key, value) => MapEntry(key, List<int>.from(value)));
// }

EvaluationResult.fromJson(Map<String, dynamic> json)
  : evaluationId = json['evaluationId'] as String,
    dateOfEvaluation = DateTime.parse(json['dateOfEvaluation'] as String),
    results = (json['results'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, List<int>.from(value)));

}

class Question {
  final String id;
  final String text;

  Question(this.id, this.text);

  Question.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      text = json['text'] as String;
}
