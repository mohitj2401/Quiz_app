import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/home.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:quiz_earn/widget/drawer.dart';
import 'dart:math' as math;
import '../providers/userprovider.dart';

class Subjects extends StatefulWidget {
  final String message;

  const Subjects({super.key, required this.message});
  @override
  _SubjectsState createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  TextEditingController searchSubject = TextEditingController();
  List subjectsGet = [];
  bool notified = false;
  late String api_token;

  late Future getDataFun;
  final formKey = GlobalKey<FormState>();
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
    if (widget.message != '' && !notified) {
      Future(() {
        final snackBar = SnackBar(content: Text(widget.message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
      notified = true;
    }
    getDataFun = getData();
    getUserData();
    super.initState();
  }

  getUserData() async {
    String url = base_url + "/api/user";
    try {
      var api = await HelperFunctions.getUserApiKey();

      if (api != '') {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api',
          "X-Requested-With": "XMLHttpRequest"
        })).get(url);

        if (response.data['status'] == 200) {
          context.read<User>().updateUser(response.data['output']['name'],
              response.data['output']['email']);
        }
      }
    } catch (e) {
      print("error on feching user data");
    }
  }

  getData() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      String url = base_url + "/api/subjects";

      try {
        Response response = await Dio(BaseOptions(headers: {
          'Authorization': 'Bearer $api',
          "X-Requested-With": "XMLHttpRequest"
        })).get(url);

        if (response.data['status'] == 200) {
          return response.data['output'];
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

  updateData(url) async {
    try {
      Response response = await Dio(BaseOptions(headers: {
        'Authorization': 'Bearer $api_token',
        "X-Requested-With": "XMLHttpRequest"
      })).get(url);

      if (response.data['status'] == 200) {
        return response.data['output'];
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

  Future<void> _handleRefresh() async {
    setState(() {
      getDataFun = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(
        title: const Text(
          'Categories',
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              NAlertDialog(
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: searchSubject,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Subject Name",
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      child: const Text("Search"),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);

                          String url = base_url +
                              "/api/subjects/search/" +
                              searchSubject.text;
                          setState(() {
                            searchSubject.text = '';
                            getDataFun = updateData(url);
                          });
                        }
                      }),
                ],
              ).show(context);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 25),
              child: Icon(
                Icons.search,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                getDataFun = getData();
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                Icons.refresh,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: FutureBuilder(
            future: getDataFun,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
                  List subjectsGet = snapshot.data as List;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: subjectsGet.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                      subject_id: subjectsGet[index]['id'],
                                      subject_name: subjectsGet[index]
                                          ['name'])));
                        },
                        child: Card(
                          color: Color((math.Random().nextDouble() * 0xFFFFF)
                                  .toInt())
                              .withOpacity(0.5),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              subjectsGet[index]['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                  return ListView.builder(
                      itemCount: subjectsGet.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home(
                                        subject_id: subjectsGet[index]['id'],
                                        subject_name: subjectsGet[index]
                                            ['name'])));
                          },
                          leading: const Icon(Icons.subject),
                          title: Text(subjectsGet[index]['name']),
                          subtitle: Text(subjectsGet[index]['code']),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF303030),
                            size: 20,
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return const Center(
                      child: Text(
                    'No result Found',
                  ));
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
