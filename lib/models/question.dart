class Question {
  String title = "";
  List<String> _incorrectAnswers = [];
  String _correctAnswer = "";

  Question(this.title, this._incorrectAnswers, this._correctAnswer);
  Question.fromJson(Map json)
      : title = json["title"],
        _incorrectAnswers = List<String>.from(json["incorrect_answers"]),
        _correctAnswer = json["correct_answer"];

  List<String> get options {
    List<String> options = [];
    options.addAll(_incorrectAnswers);
    options.add(_correctAnswer);
    options.shuffle();
    return options;
  }

  bool get answerIsWrite => selectedAnswer == _correctAnswer;

  String selectedAnswer;
}