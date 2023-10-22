import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/views/feedback.dart';
import 'package:quiz_earn/views/settings.dart';
import '../helper/helper.dart';
import '../providers/userprovider.dart';
import '../views/played_quiz.dart';
import '../views/signin.dart';
import '../views/subjects.dart';

Drawer appDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 250,
            child: DrawerHeader(
              child: Column(
                children: [
                  Image.asset(
                    "assets/appicon.png",
                    width: 100,
                  ),
                  const Text(
                    "Hello!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    context.watch<User>().name != ''
                        ? "${context.watch<User>().name[0].toUpperCase()}${context.watch<User>().name.substring(1).toLowerCase()}"
                        : "",
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
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
                      builder: (context) => const Subjects(message: '')));
            },
            leading: const Icon(Icons.subject_outlined, size: 30),
            title: const Text(
              "Categories",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const PlayedQuiz()));
            },
            leading: const Icon(
              Icons.category_outlined,
              size: 30,
            ),
            title: const Text(
              "Results",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FeedbackScrean()));
            },
            leading: const Icon(Icons.feedback_sharp, size: 30),
            title: const Text(
              "Feedback",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingScreen(
                            message: '',
                          )));
            },
            leading: const Icon(Icons.settings_outlined, size: 30),
            title: const Text(
              "Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () async {
              Navigator.pop(context);
              await NDialog(
                title: const Text(
                  "Log Out",
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  "Are you sure!",
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () async {
                      try {
                        Navigator.pop(context);
                        ProgressDialog progressDialog = ProgressDialog(context,
                            message: const Text("Logging Out"));

                        progressDialog.show();

                        String url = base_url + "/api/logout";
                        String apiToken =
                            await HelperFunctions.getUserApiKey();
                        Response response = await Dio(BaseOptions(headers: {
                          'Authorization': 'Bearer $apiToken',
                          "X-Requested-With": "XMLHttpRequest"
                        })).post(url);

                        if (response.data['status'] == 200) {
                          await HelperFunctions.saveUserLoggedIn(false);
                          await HelperFunctions.saveUserApiKey("");

                          progressDialog.dismiss();
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SignIn()),
                              (route) => false);
                        } else if (response.data['status'] == 401) {
                          await HelperFunctions.saveUserLoggedIn(false);
                          await HelperFunctions.saveUserApiKey("");

                          progressDialog.dismiss();
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const SignIn()),
                              (route) => false);
                        } else {
                          progressDialog.dismiss();
                          await NDialog(
                              title: const Text("Please contact Admin"),
                              actions: <Widget>[
                                TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ]).show(context);
                        }
                      } catch (e) {
                        await NDialog(
                            title: const Text("Please contact Admin"),
                            actions: <Widget>[
                              TextButton(
                                  child: const Text("Ok"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ]).show(context);
                      }
                    },
                  ),
                  TextButton(
                      child: const Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ).show(context);
            },
            leading: const Icon(Icons.exit_to_app_outlined, size: 30),
            title: const Text(
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
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
