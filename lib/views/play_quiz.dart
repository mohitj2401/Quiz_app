import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/models/questions.dart';
import 'package:quiz_earn/views/subjects.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:ndialog/ndialog.dart';
import 'package:quiz_earn/views/quiz_play_widget.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:html/dom.dart' as dom;

class PlayQuiz extends StatefulWidget {
  final String quizId;
  final String quizName;
  final int duration;
  PlayQuiz(this.quizId, this.duration, this.quizName);
  @override
  _PlayQuizState createState() => _PlayQuizState();
}

Map userResultMap = {};
int page = 0;
late int totalPage;

class _PlayQuizState extends State<PlayQuiz> with WidgetsBindingObserver {
  // DatabaseService databaseService = new DatabaseService();
  get wantKeepAlive => true;
  late String apiToken;
  int alertCount = 2;
  List questionSnapshot = [];
  late int endTime;

  QuestionModel getQuestionModelFromDataSnapshot(questionSnapshot, index) {
    QuestionModel questionModel = new QuestionModel();
    questionModel.question = questionSnapshot[index]['title'];
    questionModel.questionId = questionSnapshot[index]['id'];
    List<String> options = [
      questionSnapshot[index]['option1'],
      questionSnapshot[index]['option2'],
      questionSnapshot[index]['option3'],
      questionSnapshot[index]['option4'],
    ];

    options.shuffle();
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.answred = false;
    questionModel.correctOption = questionSnapshot[index]['option1'];
    return questionModel;
  }

  @override
  void initState() {
    loadQuestions(page);
    page = 0;
    Wakelock.enable();

    super.initState();
    endTime = DateTime.now().millisecondsSinceEpoch +
        1000 * 60 * widget.duration +
        15;
  }

  @override
  void dispose() {
    Wakelock.disable();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (alertCount != 0) {
        await NAlertDialog(
          dismissable: false,
          dialogStyle: DialogStyle(titleDivider: true),
          title: Text("Don't Exit Test Window"),
          content: Text("Remaing Attempt is $alertCount"),
          actions: <Widget>[
            TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ).show(context);
        alertCount--;
      } else {
        submitQuiz();
      }
    }
  }

  getdata(page) async {
    await HelperFunctions.getUserApiKey().then((value) {
      setState(() {
        apiToken = value;
      });
    });

    if (apiToken == '') {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    }

    Response response = await Dio(BaseOptions(headers: {
      'Authorization': 'Bearer $apiToken',
      "X-Requested-With": "XMLHttpRequest"
    })).get(base_url + "/api/questions/" + widget.quizId,
        queryParameters: {"page": page});

    if (response.data['status'] == 200) {
      totalPage = response.data['output'].length;
      return response.data['output'];
    } else if (response.data['status'] == 401) {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    } else {
      await NAlertDialog(
        dismissable: false,
        dialogStyle: DialogStyle(titleDivider: true),
        title: Text(response.data['message']),
        actions: <Widget>[
          TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ).show(context);
    }
  }

  loadQuestions(page) async {
    await getdata(page).then((res) async {
      setState(() {
        questionSnapshot = res;
      });
    });
  }

  updateQuestions(page) async {
    // print(page);
    setState(() {
      page = page + 1;
    });
  }

  submitQuiz() async {
    CustomProgressDialog progressDialog =
        CustomProgressDialog(context, blur: 10);

    progressDialog.show();
    List userResultList = [];
    userResultMap.forEach((key, value) {
      userResultList.add({
        'id': key,
        'answer': value,
      });
    });

    try {
      Response response = await Dio(BaseOptions(headers: {
        'Authorization': 'Bearer $apiToken',
        "X-Requested-With": "XMLHttpRequest"
      })).post(base_url + "/api/result/store", data: {
        "data1": jsonEncode(userResultList),
        'quizId': widget.quizId,
      });
      //  print(response);
      userResultMap = {};

      if (response.data['status'] == '200') {
        userResultList = [];

        progressDialog.dismiss();
        NAlertDialog(
          blur: 10,
          dismissable: false,
          dialogStyle: DialogStyle(),
          title: Text("Your Quiz is Completed"),
        ).show(context);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Subjects(message: 'Quiz Attempted')),
            (route) => false);
      } else {
        progressDialog.dismiss();

        await NAlertDialog(
          dismissable: false,
          dialogStyle: DialogStyle(titleDivider: true),
          title: Text("Opps Something Went Worng!"),
          content: Text("Please check your connectivity and try Again.."),
          actions: <Widget>[
            TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ).show(context);
      }
    } catch (e) {
      await NAlertDialog(
        dismissable: false,
        dialogStyle: DialogStyle(titleDivider: true),
        title: Text("Opps Something Went Worng!"),
        content: Text("Please check your connectivity and try Again.."),
        actions: <Widget>[
          TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await NDialog(
          dialogStyle: DialogStyle(titleDivider: true),
          title: Text("Are you sure! You want to continue."),
          content: Text("Quiz is going to be saved"),
          actions: <Widget>[
            TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  submitQuiz();
                }),
            TextButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ).show(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quizName,
            style: TextStyle(color: Colors.blueAccent, fontSize: 22),
          ),
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                await NDialog(
                  dialogStyle: DialogStyle(titleDivider: true),
                  title: Text("Are you sure! You want to continue."),
                  content: Text("Quiz is going to be saved"),
                  actions: <Widget>[
                    TextButton(
                        child: Text("Yes"),
                        onPressed: () async {
                          submitQuiz();
                        }),
                    TextButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ).show(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await NDialog(
                  dialogStyle: DialogStyle(titleDivider: true),
                  title: Text("Log Out"),
                  content: Text("Are you sure!.Process is going to be saved"),
                  actions: <Widget>[
                    TextButton(
                        child: Text("Yes"),
                        onPressed: () async {
                          submitQuiz();
                        }),
                    TextButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ).show(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.done_all_sharp),
              ),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: questionSnapshot != null && questionSnapshot.isNotEmpty
              ? Column(
                  children: [
                    CountdownTimer(
                      endTime: endTime,
                      widgetBuilder: (_, CurrentRemainingTime? time) {
                        if (time == null || time.sec! < 5 && time.min == null) {
                          return Text(
                            'Quiz is going to submit',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 21,
                            ),
                          );
                        }
                        if (time.sec! < 25 && time.min == null) {
                          return Text(
                            'Quiz is going to submit after ${time.sec} sec',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 21,
                            ),
                          );
                        }
                        return Text(
                            'Remaning Time:- ${time.min ?? '00'}:${time.sec} ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 21,
                            ));
                      },
                      onEnd: submitQuiz,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: QuizPlayTile(
                            questionModel: getQuestionModelFromDataSnapshot(
                                questionSnapshot, page),
                            page: page,
                            onTap: () {
                              if (totalPage == (page + 1)) {
                                submitQuiz();
                              } else {
                                setState(() {
                                  page = page + 1;
                                });
                              }
                            }),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),

        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.check),
        //   onPressed: submitQuiz,
        // ),
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;

  final int page;
  // final bool disable;
  final VoidCallback onTap;
  QuizPlayTile({
    required this.questionModel,
    required this.page,
    required this.onTap,
    // required this.disable,
  });

  @override
  _QuizPlayTileState createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile>
    with AutomaticKeepAliveClientMixin {
  get wantKeepAlive => true;
  String optionSelected = "";
  bool disable = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: [
        if (widget.questionModel.question != "")
          Expanded(
            child: Html(
              shrinkWrap: true,
              data: widget.questionModel.question,
              onImageTap: (String? url, RenderContext context,
                  Map<String, String> attributes, dom.Element? element) async {
                url = url as String;
                await ZoomDialog(
                  zoomScale: 5,
                  child: Container(
                    child: Image(image: NetworkImage(url)),
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                  ),
                ).show(super.context);
              },
            ),
          ),
        Spacer(),
        SizedBox(height: 4),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                userResultMap.addAll({
                  widget.questionModel.questionId: widget.questionModel.option1,
                });
                if (widget.questionModel.answred) {
                  if (widget.questionModel.option1 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option1;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option1;

                    setState(() {});
                  }
                } else {
                  if (widget.questionModel.option1 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answred = true;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option1;
                    widget.questionModel.answred = true;

                    setState(() {});
                  }
                }
              },
              child: QuestionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option1,
                optionSelcted: optionSelected,
                option: "A",
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                userResultMap.addAll({
                  widget.questionModel.questionId: widget.questionModel.option2,
                });
                if (widget.questionModel.answred) {
                  if (widget.questionModel.option2 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option2;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option2;

                    setState(() {});
                  }
                } else {
                  if (widget.questionModel.option2 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answred = true;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option2;
                    widget.questionModel.answred = true;

                    setState(() {});
                  }
                }
              },
              child: QuestionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option2,
                optionSelcted: optionSelected,
                option: "B",
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                userResultMap.addAll({
                  widget.questionModel.questionId: widget.questionModel.option3,
                });
                if (widget.questionModel.answred) {
                  if (widget.questionModel.option3 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option3;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option3;

                    setState(() {});
                  }
                } else {
                  if (widget.questionModel.option3 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answred = true;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option3;
                    widget.questionModel.answred = true;

                    setState(() {});
                  }
                }
              },
              child: QuestionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option3,
                optionSelcted: optionSelected,
                option: "C",
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                userResultMap.addAll({
                  widget.questionModel.questionId: widget.questionModel.option4,
                });
                if (widget.questionModel.answred) {
                  if (widget.questionModel.option4 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option4;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option4;

                    setState(() {});
                  }
                } else {
                  if (widget.questionModel.option4 ==
                      widget.questionModel.correctOption) {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answred = true;

                    setState(() {});
                  } else {
                    optionSelected = widget.questionModel.option4;
                    widget.questionModel.answred = true;

                    setState(() {});
                  }
                }
              },
              child: QuestionTile(
                correctAnswer: widget.questionModel.correctOption,
                description: widget.questionModel.option4,
                optionSelcted: optionSelected,
                option: "D",
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Spacer(),
        (page + 1) != totalPage
            ? Container(
                padding: EdgeInsets.only(bottom: 5),
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.blue, // <-- Button color
                    onPrimary: Colors.white, // <-- Splash color
                  ),
                  onPressed: widget.onTap,
                  child: Icon(Icons.arrow_right_alt_sharp),
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: 5),
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.blue, // <-- Button color
                    onPrimary: Colors.white, // <-- Splash color
                  ),
                  onPressed: widget.onTap,
                  child: Icon(Icons.check),
                ),
              )
      ],
    );
  }
}
