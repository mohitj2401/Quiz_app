import 'package:provider/provider.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/providers/themeprovider.dart';
import 'package:quiz_earn/providers/userprovider.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:quiz_earn/views/subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => User()),
      ChangeNotifierProvider(create: (_) => ThemeProviders())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    var themeIndex = await HelperFunctions.getUserThemeKey();
    if (themeIndex != -1) {
      await context.read<ThemeProviders>().updateTheme(themeIndex);
    } else {
      await context.read<ThemeProviders>().updateTheme(0);
    }
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
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Quiz Learn',
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProviders>(context).themeData,
        home: isLoading
            ? Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _isLoggedIn
                ? const Subjects(
                    message: '',
                  )
                : const SignIn(),
      );
    });
  }
}
