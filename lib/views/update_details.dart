import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/myaccount.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

import '../providers/userprovider.dart';

class UpdateDetails extends StatefulWidget {
  const UpdateDetails({super.key});

  @override
  _UpdateDetailsState createState() => _UpdateDetailsState();
}

late String api_token;

class _UpdateDetailsState extends State<UpdateDetails> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = true;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();

  Map userdata = {};
  getData() async {
    var api = await HelperFunctions.getUserApiKey();
    if (api != null || api != '') {
      String url = base_url + "/api/user";

      try {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api',
          "X-Requested-With": "XMLHttpRequest"
        })).get(url);

        if (response.data['status'] == 200) {
          emailTextEditingController.text = response.data['output']['email'];
          nameTextEditingController.text = response.data['output']['name'];
          setState(() {
            isLoading = false;
          });
        } else if (response.data['status'] == '404') {
          await HelperFunctions.saveUserLoggedIn(false);
          await HelperFunctions.saveUserApiKey("");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
              (route) => false);
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
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

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();

    if (api_token == '') {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => const SignIn()), (route) => false);
    }
  }

  @override
  void initState() {
    storeapi();
    getData();
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
        })).post(base_url + "/api/update-details", data: {
          "name": nameTextEditingController.text,
          "email": emailTextEditingController.text,
        });

        if (response.data['status'] == 200) {
          context.read<User>().updateUser(
              nameTextEditingController.text, emailTextEditingController.text);
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyAccount(
                        message: 'User Details Updated',
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
              MaterialPageRoute(builder: (context) => const SignIn()),
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
                  child: const Text("Ok"),
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
      appBar: AppBar(
        title: const Center(
            child: Text(
          "User Update",
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: isLoading
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: formKey,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: <Widget>[
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Update Your Details',
                              textStyle: const TextStyle(
                                fontSize: 35,
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

                            if (!RegExp(r"^[a-zA-Z][a-zA-Z ]+$")
                                .hasMatch(value)) {
                              return 'Please enter valid name';
                            }
                            return null;
                          },
                          controller: nameTextEditingController,
                          decoration: const InputDecoration(
                              labelText: "Name",
                              icon: Icon(Icons.person_rounded)),
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
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            signUp();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: MediaQuery.of(context).size.width - 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Update",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ),
                        const SizedBox(
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
}
