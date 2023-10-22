import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/change_pass.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:quiz_earn/views/update_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widget/drawer.dart';

class MyAccount extends StatefulWidget {
  final String message;
  MyAccount({required this.message});
  @override
  _MyAccountState createState() => _MyAccountState();
}

String api_token = '';

class _MyAccountState extends State<MyAccount> {
  bool isLoading = true;
  bool isStarted = false;
  Map quizdetails = {};
  bool notified = false;

  getData() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      String url = base_url + "/api/user";

      try {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api',
          "X-Requested-With": "XMLHttpRequest"
        })).get(url);

        if (response.data['status'] == 200) {
          quizdetails = response.data['output'];
          setState(() {
            isLoading = false;
          });
        } else if (response.data['status'] == 401) {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false);
        } else {
          setState(() {
            isLoading = false;
          });
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
      } catch (e) {
        setState(() {
          isLoading = false;
        });

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
  }

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();

    if (api_token == '') {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    }
  }

  @override
  void initState() {
    storeapi();

    getData();

    if (widget.message != '' && !notified) {
      Future(() {
        final snackBar = SnackBar(content: Text(widget.message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
      notified = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
        ),
      ),
      drawer: appDrawer(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      child: Card(
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.person_rounded,
                          // size: 20.sp,
                        ),
                      ),
                    ),
                    Center(
                        child: Icon(
                      Icons.person_rounded,
                      size: 100,
                    )),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        Text('Name'),
                        Spacer(),
                        Text(quizdetails['name']),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Email'),
                        Spacer(),
                        Text(quizdetails['email']),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Quiz Attempted'),
                        Spacer(),
                        quizdetails['result_count'].toString() != ''
                            ? Text(quizdetails['result_count'].toString())
                            : Text('0'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateDetails(),
                                ),
                              );
                            },
                            child: Text('Update Details'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePass(),
                                ),
                              );
                            },
                            child: Text('Change Password'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
