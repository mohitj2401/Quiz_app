import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/service/auth.dart';

import 'package:quiz_earn/views/signup.dart';
import 'package:quiz_earn/views/subjects.dart';
import 'package:dio/dio.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  bool showError = false;
  bool _isHidden = true;
  final formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  signIn() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        Response response = await Dio(
                BaseOptions(headers: {"X-Requested-With": "XMLHttpRequest"}))
            .post(base_url + "/api/login", data: {
          "email": emailTextEditingController.text,
          'password': passwordTextEditingController.text,
        });

        authService.error = '';
        if (response.data['email'] != null) {
          authService.error = response.data['email'][0].toString();

          setState(() {
            isLoading = false;
          });
        } else {
          if (response.data['status'] == 200) {
            await HelperFunctions.saveUserApiKey(
                response.data['output']['access_token']);

            await HelperFunctions.saveUserLoggedIn(true);
            await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Subjects(
                          message: 'Login successfully',
                        )));
            setState(() {
              isLoading = false;
            });
          } else {
            authService.error = response.data['message'];
            setState(() {
              isLoading = false;
            });
          }
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
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
                      margin:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: <Widget>[
                          showAlert(),
                          SizedBox(height: 20),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Hello There!',
                                textStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                speed: Duration(milliseconds: 100),
                              ),
                            ],
                            pause: Duration(milliseconds: 500),
                            displayFullTextOnTap: true,
                          ),
                          SizedBox(height: 50),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return "Please enter valid email";
                              }
                              return null;
                            },
                            controller: emailTextEditingController,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.email_rounded,
                              ),
                              labelText: "Email",
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            obscureText: _isHidden,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please Enter Password";
                              } else {
                                return null;
                              }
                            },
                            controller: passwordTextEditingController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 20),
                                  child: Icon(
                                    Icons.visibility,
                                    size: 24,
                                    color:
                                        _isHidden ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                              labelText: "Password",
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              signIn();
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
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Don't have Account? ",
                                style: TextStyle(fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      )),
                ),
              ),
            ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Widget showAlert() {
    if (authService.error != '') {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(authService.error),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  authService.error = '';
                });
              },
            )
          ],
        ),
      );
    } else {
      return SizedBox(height: 0);
    }
  }
}
