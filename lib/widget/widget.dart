import 'package:quiz_earn/helper/helper.dart';

import 'package:quiz_earn/views/home.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:quiz_earn/widget/dialog.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:ndialog/ndialog.dart';

import 'package:flutter/material.dart';

PreferredSizeWidget appBarMain(BuildContext context) {
  return AppBar(
    title: Center(
        child: Text(
      "Quiz Earn",
      style: TextStyle(color: Colors.blue, fontSize: 24),
    )),
    iconTheme: IconThemeData(color: Colors.black),
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    actions: <Widget>[
      GestureDetector(
        onTap: () async {
          await NDialog(
            dialogStyle: DialogStyle(titleDivider: true),
            title: Text("Log Out"),
            content: Text("Are you sure!.Process is going to delete"),
            actions: <Widget>[
              TextButton(
                  child: Text("Yes"),
                  onPressed: () async {
                    await HelperFunctions.saveUserApiKey('');

                    await HelperFunctions.saveUserLoggedIn(false);
                    await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                        (route) => false);
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
    ],
  );
}

Widget appBarMainWithoutSignout(BuildContext context) {
  return AppBar(
    title: Center(
        child: Text(
      "Quiz Earn",
      style: TextStyle(color: Colors.blue, fontSize: 24),
    )),
    iconTheme: IconThemeData(color: Colors.black),
    backgroundColor: Colors.transparent,
    elevation: 0.0,
  );
}

Widget appDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,

      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                ),
              ),
              Expanded(
                child: Text(
                  "dummy",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('QuizResults'),
          onTap: () {
            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => QuizResult()));
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('My Account'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Setting'),
          onTap: () {
            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => MyAccount()));
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            Dialogs.yesAbortDialogNew(context, "Are you sure?",
                "Do you really want to Logout?", SignIn());
          },
        ),
      ],
    ),
  );
}

Future<void> showMyDialog(BuildContext context, String successmessage) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(successmessage),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
