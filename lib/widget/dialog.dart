import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

enum DialogAction { yes, abort }

AuthService authService = AuthService();

class Dialogs {
  static Future<DialogAction> yesAbortDialog(
    BuildContext context,
    String title,
    String body,
    String quizId,
    Function newful,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.abort),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                try {
                  Response response = await Dio().post(
                    base_url +
                        "/api/quiz/delete/1610699043LzzFWZHFKbaiatVLjO6kYvaWBJ6zFg/" +
                        quizId,
                  );
                } catch (e) {}
                newful();
                Navigator.of(context).pop(DialogAction.yes);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogAction.abort;
  }

  static Future<DialogAction> yesAbortDialogNew(
    BuildContext context,
    String title,
    String body,
    Widget navigateTo,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(DialogAction.abort),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                // authService.signOut();

                await HelperFunctions.saveUserLoggedIn(false);
                await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => navigateTo),
                    (route) => false);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : DialogAction.abort;
  }
}
