import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/service/auth.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:quiz_earn/views/subjects.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../providers/userprovider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isHidden = true;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  Logger logger = Logger();

  signUp() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        Response response = await Dio(
                BaseOptions(headers: {"X-Requested-With": "XMLHttpRequest"}))
            .post(base_url + "/api/register", data: {
          "name": nameTextEditingController.text,
          "email": emailTextEditingController.text,
          'password': passwordTextEditingController.text,
        });
        logger.i(response);
        if (response.data['email'] != null) {
          authService.error = response.data['email'][0].toString();

          setState(() {
            isLoading = false;
          });
        } else {
          if (response.data['status'] == 200) {
            context.read<User>().updateUser(
                response.data['output']['user']['name'],
                response.data['output']['user']['email']);
            await HelperFunctions.saveUserApiKey(
                response.data['output']['access_token']);
            await HelperFunctions.saveUserLoggedIn(true);
            await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Subjects(message: 'Resgiter Successfully')));

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        logger.i(e.toString());
        setState(() {
          isLoading = false;
        });
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 100,
                  ),
                  showAlert(),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome to Quiz Learn!',
                        textStyle: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    pause: const Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Name";
                      }

                      if (!RegExp(r"^[a-zA-Z][a-zA-Z ]+$").hasMatch(value)) {
                        return 'Please enter valid name';
                      }
                      return null;
                    },
                    controller: nameTextEditingController,
                    decoration: const InputDecoration(
                        labelText: "Name", icon: Icon(Icons.person_rounded)),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return "Please enter valid email";
                      }
                      return null;
                    },
                    controller: emailTextEditingController,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.email_rounded,
                      ),
                      labelText: "Email",
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    obscureText: _isHidden,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Password";
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
                      icon: const Icon(Icons.lock),
                      suffix: InkWell(
                        onTap: _togglePasswordView,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 20),
                          child: Icon(
                            Icons.visibility,
                            size: 24,
                            color: _isHidden ? Colors.grey : Colors.blueGrey,
                          ),
                        ),
                      ),
                      labelText: "Password",
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () {
                      signUp();
                    },
                    child: isLoading
                        ? Container(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: MediaQuery.of(context).size.width - 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Sign Up",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignIn()));
                        },
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  )
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
      _isHidden = !_isHidden;
    });
  }

  Widget showAlert() {
    if (authService.error != '') {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(authService.error),
            ),
            IconButton(
              icon: const Icon(Icons.close),
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
      return const SizedBox(height: 0);
    }
  }
}
