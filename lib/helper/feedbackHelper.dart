import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:dio/dio.dart';
import 'package:quiz_earn/views/signin.dart';

class Feedbackhelper {
  saveFeedback(context, Map<String, dynamic> feedbackData) async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      String url = base_url + "/api/feedback";

      try {
        Response response = await Dio(BaseOptions(headers: {
          "X-Requested-With": "XMLHttpRequest",
          'Authorization': 'Bearer $api',
        })).post(url, data: {
          "subject": feedbackData['title'],
          'message': feedbackData['message'],
          "rating": feedbackData["rating"]
        });

        if (response.data['status'] == 200) {
          return true;
        } else if (response.data['status'] == 401) {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
              (route) => false);
        } else {
          await NAlertDialog(
            dismissable: false,
            dialogStyle: DialogStyle(titleDivider: true),
            title: const Text("Something Went Wrong."),
            actions: <Widget>[
              TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ).show(context);
          return false;
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
        return false;
      }
    }
  }
}
