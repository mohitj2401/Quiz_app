import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_elevated_button/loading_elevated_button.dart';
import 'package:quiz_earn/constant/feedbackCard.dart';
import 'package:quiz_earn/helper/feedbackHelper.dart';
import 'package:quiz_earn/service/auth.dart';

class FeedbackScrean extends StatefulWidget {
  const FeedbackScrean({Key? key}) : super(key: key);

  @override
  State<FeedbackScrean> createState() => _FeedbackScreanState();
}

class _FeedbackScreanState extends State<FeedbackScrean> {
  bool isLoading = false;
  bool isSubmit = false;
  bool showError = false;
  List<int> selectedList = [];

  final formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  double rating = 3;
  String imporvements = '';
  final Feedbackhelper _feedbackhelper = Feedbackhelper();

  TextEditingController messageTextEditingController = TextEditingController();

  sumbitFeedback() async {
    setState(() {
      isSubmit = true;
    });
    String title = '';
    for (var element in selectedList) {
      if (element == 1) {
        title = title + 'Quiz Ui ,';
      }
      if (element == 2) {
        title = title + 'App Services ,';
      }
      if (element == 3) {
        title = title + 'App Ui ,';
      }
      if (element == 4) {
        title = title + 'App Functionality ,';
      }
    }
    Map<String, dynamic> feedbackdata = {
      "rating": rating,
      "title": title,
      "message": messageTextEditingController.text
    };
    var value = await _feedbackhelper.saveFeedback(context, feedbackdata);

    setState(() {
      isLoading = value;
      // isSubmit = !value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: LoadingElevatedButton(
                isLoading: isSubmit,
                disabledWhileLoading: isSubmit,
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(),
                    ),
                  ),
                ),
                onPressed: () {
                  sumbitFeedback();
                },
              ),
            ),
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Feedback',
        ),
      ),
      body: isLoading
          ? const SubmitedFeedbackScreen()
          : Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rate Your Experience",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Are you Satisfied with our Service ?",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          RatingBar.builder(
                            initialRating: rating,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return const Icon(
                                    Icons.sentiment_very_dissatisfied,
                                    color: Colors.red,
                                  );
                                case 1:
                                  return const Icon(
                                    Icons.sentiment_dissatisfied,
                                    color: Colors.redAccent,
                                  );
                                case 2:
                                  return const Icon(
                                    Icons.sentiment_neutral,
                                    color: Colors.amber,
                                  );
                                case 3:
                                  return const Icon(
                                    Icons.sentiment_satisfied,
                                    color: Colors.lightGreen,
                                  );
                                case 4:
                                  return const Icon(
                                    Icons.sentiment_very_satisfied,
                                    color: Colors.green,
                                  );
                              }
                              return const Icon(
                                Icons.sentiment_satisfied,
                              );
                            },
                            onRatingUpdate: (value) {
                              setState(() {
                                rating = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tell us what can be Improved?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              feedbackCard(
                                "Quiz UI",
                                () {
                                  if (selectedList.contains(1)) {
                                    setState(() {
                                      selectedList.remove(1);
                                    });
                                  } else {
                                    setState(() {
                                      selectedList.add(1);
                                    });
                                  }
                                },
                                context,
                                selectedCard:
                                    selectedList.contains(1) ? true : false,
                              ),
                              feedbackCard(
                                "App Services",
                                () {
                                  if (selectedList.contains(2)) {
                                    setState(() {
                                      selectedList.remove(2);
                                    });
                                  } else {
                                    setState(() {
                                      selectedList.add(2);
                                    });
                                  }
                                },
                                context,
                                selectedCard:
                                    selectedList.contains(2) ? true : false,
                              ),
                              feedbackCard(
                                "App UI",
                                () {
                                  if (selectedList.contains(3)) {
                                    setState(() {
                                      selectedList.remove(3);
                                    });
                                  } else {
                                    setState(() {
                                      selectedList.add(3);
                                    });
                                  }
                                },
                                context,
                                selectedCard:
                                    selectedList.contains(3) ? true : false,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              feedbackCard(
                                "App Functionality",
                                () {
                                  if (selectedList.contains(5)) {
                                    setState(() {
                                      selectedList.remove(5);
                                    });
                                  } else {
                                    setState(() {
                                      selectedList.add(5);
                                    });
                                  }
                                },
                                context,
                                selectedCard:
                                    selectedList.contains(5) ? true : false,
                              ),
                              Container()
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Form(
                            key: formKey,
                            child: TextFormField(
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              controller: messageTextEditingController,
                              decoration: const InputDecoration(
                                hintText: "Tell us how can we improve...",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class SubmitedFeedbackScreen extends StatelessWidget {
  const SubmitedFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.thumb_up_off_alt,
            size: 80,
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Thank You",
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Your Feedback was Successfully Submitted.",
            style: TextStyle(
                fontSize: 18, color: Colors.blueAccent.withOpacity(0.7)),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.red.withOpacity(0.6),
                ),
                Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
