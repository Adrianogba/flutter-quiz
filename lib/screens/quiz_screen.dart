import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiz/models/question.dart';
import 'package:flutter_quiz/utils/crashlytics_utils.dart';

class QuizScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool loading = true;
  bool error = false;
  int current = 0;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    getQuestionsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: getBody()),
    );
  }

  Widget getBody() {
    if (loading) {
      return CircularProgressIndicator();
    }

    if (error) {
      return getTryAgainBody('Falha ao obter Quiz');
    }

    if (questions.isEmpty) {
      return Text('Inconsistencia nos dados. Favor entrar em contato com o administrador', textAlign: TextAlign.center);
    }

    if (current >= questions.length) {
      int qtWriteAnswers = questions.where((question) => question.answerIsWrite).length;
      var correctAnswersPercentage = (100 / questions.length) * qtWriteAnswers;

      var msg = 'Você acertou $correctAnswersPercentage%.';
      if (correctAnswersPercentage == 100) {
        msg += ' Parabéns!!';
      } else if (correctAnswersPercentage == 0) {
        msg += ' Boa sorte na próxima!';
      }

      return getTryAgainBody(msg);
    }

    var currentQuestion = questions[current];
    List<ListTile> listOfOptions = [];
    currentQuestion.options.forEach((option) {
      listOfOptions.add(ListTile(
        title: CupertinoButton(
            padding: EdgeInsets.all(15),
            color: Colors.blue,
            onPressed: () {
              currentQuestion.selectedAnswer = option;
              current += 1;
              setState(() {});
            },
            child: Text(option)),
      ));
    });

    return ListView(
      shrinkWrap: true,
      children: [
        Text(currentQuestion.title, textAlign: TextAlign.center),
        ListView(
          shrinkWrap: true,
          children: listOfOptions,
        )
      ],
    );
  }

  getTryAgainBody(String titleMessage) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(titleMessage, textAlign: TextAlign.center),
        Container(
          margin: EdgeInsets.all(15),
          child: CupertinoButton(
            padding: EdgeInsets.all(15),
            color: Colors.blue,
            onPressed: () {
              getQuestionsList();
            },
            child: Text('Tentar novamente')),)
      ],
    );
  }

  getQuestionsList() async {
    loading = true;
    error = false;
    current = 0;
    questions.clear();
    FirebaseFirestore.instance.collection('questions').get().then((snapshot) {
      loading = false;
      try {
        List<QueryDocumentSnapshot> snapshotList = snapshot.docs;
        snapshotList.shuffle();
        snapshotList.forEach((snapshot) => questions.add(Question.fromJson(snapshot.data())));
        if (questions.isEmpty) {
          error = true;
          logMessage('Collection is empty');
        }
      } catch (e) {
        error = true;
        logException(e);
      }
      setState(() {});
    }).catchError((err) {
      error = true;
      logMessage(err.toString());
      setState(() {});
    });
  }
}
