class Evaluation {
  final String id;
  final String name;
  final DateTime creationDate;
  final List<String> questionIds;

  Evaluation(this.id, this.name, this.creationDate, this.questionIds);

  Evaluation.fromJson(Map<String, dynamic> json)
  : id = json['id'] as String,
  name = json['name'] as String,
  creationDate = json['creationDate'] as DateTime,
  questionIds = json['questionIds'] as List<String>;
}

class EvaluationResult {
  final String evaluationId;
  final DateTime dateOfEvaluation;
  final List<Result> results;

  EvaluationResult(this.evaluationId, this.dateOfEvaluation, this.results);

  EvaluationResult.fromJson(Map<String, dynamic> json)
    : evaluationId = json['askedQuestionId'] as String,
      dateOfEvaluation = json['dateOfEvaluation'] as DateTime,
      results = json['results']
          .map((item) => Question.fromJson(item as Map<String, dynamic>))
          .toList();
}

class Result {
  final String askedQuestionId;
  final int result;

  Result(this.askedQuestionId, this.result);

  Result.fromJson(Map<String, dynamic> json)
    : askedQuestionId = json['askedQuestionId'] as String,
      result = json['result'] as int;
}

class Question {
  final String id;
  final String text;

  Question(this.id, this.text);

  Question.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      text = json['text'] as String;
}
