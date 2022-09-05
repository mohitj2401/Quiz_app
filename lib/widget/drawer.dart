import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/views/feedback.dart';
import '../helper/helper.dart';
import '../providers/userprovider.dart';
import '../views/myaccount.dart';
import '../views/played_quiz.dart';
import '../views/signin.dart';
import '../views/subjects.dart';

Drawer appDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 250,
            child: DrawerHeader(
              child: Column(
                children: [
                  Image.asset(
                    "assets/appicon.png",
                    width: 100,
                  ),
                  Text(
                    "Hello!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    context.watch<User>().name != ''
                        ? "${context.watch<User>().name[0].toUpperCase()}${context.watch<User>().name.substring(1).toLowerCase()}"
                        : "",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Subjects(message: '')));
            },
            leading: Icon(Icons.subject_outlined, size: 30),
            title: Text(
              "Categories",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PlayedQuiz()));
            },
            leading: Icon(
              Icons.category_outlined,
              size: 30,
            ),
            title: Text(
              "Results",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FeedbackScrean()));
            },
            leading: Icon(Icons.feedback_sharp, size: 30),
            title: Text(
              "Feedback",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAccount(
                            message: '',
                          )));
            },
            leading: Icon(Icons.settings_outlined, size: 30),
            title: Text(
              "Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              await NDialog(
                title: Text(
                  "Log Out",
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  "Are you sure!",
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      try {
                        Navigator.pop(context);
                        ProgressDialog progressDialog = ProgressDialog(context,
                            message: Text("Logging Out"));

                        progressDialog.show();

                        String url = base_url + "/api/logout";
                        String api_token =
                            await HelperFunctions.getUserApiKey();
                        Response response = await Dio(BaseOptions(headers: {
                          'Authorization': 'Bearer $api_token',
                          "X-Requested-With": "XMLHttpRequest"
                        })).post(url);

                        if (response.data['status'] == 200) {
                          await HelperFunctions.saveUserLoggedIn(false);
                          await HelperFunctions.saveUserApiKey("");

                          progressDialog.dismiss();
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                              (route) => false);
                        } else if (response.data['status'] == 401) {
                          await HelperFunctions.saveUserLoggedIn(false);
                          await HelperFunctions.saveUserApiKey("");

                          progressDialog.dismiss();
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                              (route) => false);
                        } else {
                          progressDialog.dismiss();
                          await NDialog(
                              title: Text("Please contact Admin"),
                              actions: <Widget>[
                                TextButton(
                                    child: Text("Ok"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ]).show(context);
                        }
                      } catch (e) {
                        await NDialog(
                            title: Text("Please contact Admin"),
                            actions: <Widget>[
                              TextButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ]).show(context);
                      }
                    },
                  ),
                  TextButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ).show(context);
            },
            leading: Icon(Icons.exit_to_app_outlined, size: 30),
            title: Text(
              "Logout",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
          )
        ],
      ),
    ),
  );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
