import 'dart:async';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/quiz_detail.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ndialog/ndialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.subject_id, required this.subject_name})
      : super(key: key);

  final int subject_id;
  final String subject_name;

  @override
  _HomeState createState() => _HomeState();
}

late String api_token;

class _HomeState extends State<Home> {
  late StreamController _quizcontroller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool notified = false;
  Widget quizList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder(
        stream: _quizcontroller.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (snapshot.hasData && snapshot.data.length > 0) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  if (DateTime.parse(snapshot.data[index]['start_time'])
                      .isAfter(DateTime.now())) {}
                  // if (DateTime.now() < (snapshot.data[index]['start_time'])) {
                  //   print("Yes");
                  // }
                  return QuizTile(
                    title: snapshot.data[index]['title'],
                    description: snapshot.data[index]['description'],
                    imgUrl: snapshot.data[index]['image'],
                    quizId: snapshot.data[index]['id'].toString(),
                    duration: snapshot.data[index]['duration'],
                    startDate:
                        DateTime.parse(snapshot.data[index]['start_time']),
                    func: _handleRefresh,
                  );
                },
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return Container(
              alignment: Alignment.center,
              child: const Text('No Quiz Available or refresh'),
            );
          }
          return Container(
            alignment: Alignment.center,
            child: const Text('No Quiz Available or refresh'),
          );
        },
      ),
    );
  }

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();
    if (api_token == '') {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => const SignIn()), (route) => false);
    }
  }

  @override
  void initState() {
    storeapi();

    _quizcontroller = StreamController();

    loadPosts();

    super.initState();
  }

  getData() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      String url = base_url + "/api/quiz/" + widget.subject_id.toString();

      try {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api',
          "X-Requested-With": "XMLHttpRequest"
        })).get(url);
        //   print(response);
        if (response.data['status'] == 200) {
          return response.data['output'];
        } else if (response.data['status'] == 401) {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
              (route) => false);
        } else if (response.data['status'] == 400) {
          await NAlertDialog(
            dismissable: false,
            dialogStyle: DialogStyle(titleDivider: true),
            title: Text(response.data['message']),
            actions: <Widget>[
              TextButton(
                  child: const Text("Ok"),
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
          title: const Text("Opps Something Went Worng!"),
          content: const Text("Please check your connectivity and try Again.."),
          actions: <Widget>[
            TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ).show(context);
      }
    } else {
      await HelperFunctions.saveUserLoggedIn(false);
      await Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const SignIn()));
    }
  }

  loadPosts() async {
    getData().then((res) async {
      _quizcontroller.add(res);

      return res;
    });
  }

  Future<void> _handleRefresh() async {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: const Text("Loading"));

    //You can set Message using this function
    // progressDialog.setTitle(Text("Loading"));

    progressDialog.show();
    getData().then((res) async {
      _quizcontroller.add(res);
      progressDialog.dismiss();

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          widget.subject_name,
        )),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Container(
        child: quizList(),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String quizId;
  final String description;
  final int duration;
  final DateTime startDate;

  final Function func;
  const QuizTile({super.key, 
    required this.imgUrl,
    required this.title,
    required this.description,
    required this.quizId,
    required this.func,
    required this.duration,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          // startDate.isBefore(DateTime.now())
          //     ?
          () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PlayQuiz(quizId, duration),
        //   ),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetails(quizId),
          ),
        );
      },
      // : null,
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 8, top: 2),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                base_url + '/' + imgUrl,
                width: MediaQuery.of(context).size.width - 48,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black26,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        )),
                    const SizedBox(height: 6),
                    Text(description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
