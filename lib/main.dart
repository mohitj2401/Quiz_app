import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:quiz_earn/views/subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    userLoggedInStatus();

    super.initState();
  }

  userLoggedInStatus() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      setState(() {
        _isLoggedIn = true;
        isLoading = false;
      });
    } else {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey('');
      setState(() {
        _isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Earn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isLoading
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isLoggedIn
              ? Subjects(
                  message: '',
                )
              : SignIn(),
    );
  }
}
