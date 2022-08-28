import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:quiz_earn/service/auth.dart';
import 'package:quiz_earn/views/signup.dart';
import 'package:quiz_earn/widget/drawer.dart';

class FeedbackScrean extends StatefulWidget {
  FeedbackScrean({Key? key}) : super(key: key);

  @override
  State<FeedbackScrean> createState() => _FeedbackScreanState();
}

class _FeedbackScreanState extends State<FeedbackScrean> {
  bool isLoading = false;

  bool showError = false;

  bool _isHidden = true;

  final formKey = GlobalKey<FormState>();

  AuthService authService = new AuthService();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(color: Colors.blueAccent, fontSize: 22),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
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
                            onTap: () {},
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

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
