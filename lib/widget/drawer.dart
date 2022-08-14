import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:quiz_earn/constant/constant.dart';

import '../helper/helper.dart';
import '../views/myaccount.dart';
import '../views/played_quiz.dart';
import '../views/signin.dart';
import '../views/subjects.dart';

Drawer appDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 30),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                Image.asset(
                  "assets/appicon.png",
                  width: 100,
                ),
                SizedBox(height: 20),
                Text(
                  "Hello!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  "${userData['name'][0].toUpperCase()}${userData['name'].substring(1).toLowerCase()}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Subjects(message: '')));
            },
            leading: Icon(Icons.subject_outlined, size: 30),
            title: Text(
              "Subject",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PlayedQuiz()));
            },
            leading: Icon(
              Icons.category_outlined,
              size: 30,
            ),
            title: Text(
              "Results",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          Spacer(),
          ListTile(
            onTap: () {
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
                        Navigator.pop(context);
                        ProgressDialog progressDialog = ProgressDialog(context,
                            message: Text("Logging Out"));

                        progressDialog.show();

                        String url = base_url + "/api/logout";

                        Response response = await Dio(BaseOptions(headers: {
                          'Authorization': 'Bearer $api_token',
                          "X-Requested-With": "XMLHttpRequest"
                        })).post(url);

                        if (response.data['status'] == 200) {
                          await HelperFunctions.saveUserLoggedIn(false);
                          await HelperFunctions.saveUserApiKey("");

                          progressDialog.dismiss();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                              (route) => false);
                        }
                      }),
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
          ),
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
