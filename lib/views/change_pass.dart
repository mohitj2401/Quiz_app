import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/myaccount.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class ChangePass extends StatefulWidget {
  @override
  _ChangePassState createState() => _ChangePassState();
}

String api_token = '';

class _ChangePassState extends State<ChangePass> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isHidden3 = true;

  TextEditingController oldpasswordEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();

    if (api_token == '' || api_token == null) {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
    }
  }

  @override
  void initState() {
    storeapi();

    super.initState();
  }

  signUp() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api_token',
          "X-Requested-With": "XMLHttpRequest"
        })).post(base_url + "/api/update-password", data: {
          "old_pass": oldpasswordEditingController.text,
          "new_pass": passwordTextEditingController.text,
        });

        if (response.data['status'] == 200) {
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MyAccount(
                        message: 'Password changed successfully',
                      )),
              (route) => false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Quiz Learn",
        )),
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: Form(
                  key: formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          obscureText: _isHidden1,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Password";
                            }

                            return null;
                          },
                          controller: oldpasswordEditingController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            suffix: InkWell(
                              onTap: _togglePasswordView,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 20),
                                child: Icon(
                                  Icons.visibility,
                                  size: 24,
                                  color: _isHidden1
                                      ? Colors.grey
                                      : Colors.blueGrey,
                                ),
                              ),
                            ),
                            labelText: "Old Password",
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          obscureText: _isHidden2,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter New Password";
                            }
                            if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                              return 'Please enter strong password';
                            }
                            return null;
                          },
                          controller: passwordTextEditingController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            suffix: InkWell(
                              onTap: _togglePasswordView1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 20),
                                child: Icon(
                                  Icons.visibility,
                                  size: 24,
                                  color: _isHidden1
                                      ? Colors.grey
                                      : Colors.blueGrey,
                                ),
                              ),
                            ),
                            labelText: "New Password",
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          obscureText: _isHidden3,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Confirm New Password";
                            }
                            if (passwordTextEditingController.text != value) {
                              return "Password doesn't match";
                            }
                            return null;
                          },
                          controller: confirmPasswordTextEditingController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            suffix: InkWell(
                              onTap: _togglePasswordView2,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 20),
                                child: Icon(
                                  Icons.visibility,
                                  size: 24,
                                  color: _isHidden1
                                      ? Colors.grey
                                      : Colors.blueGrey,
                                ),
                              ),
                            ),
                            labelText: "Confirm New Password",
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        GestureDetector(
                          onTap: () {
                            signUp();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            width: MediaQuery.of(context).size.width - 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Sign Up",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden1 = !_isHidden1;
    });
  }

  void _togglePasswordView2() {
    setState(() {
      _isHidden3 = !_isHidden3;
    });
  }

  void _togglePasswordView1() {
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }
}
