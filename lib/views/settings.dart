import 'package:provider/provider.dart';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/providers/themeprovider.dart';
import 'package:quiz_earn/views/myaccount.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../providers/userprovider.dart';
import '../widget/drawer.dart';

class SettingScreen extends StatefulWidget {
  final String message;
  const SettingScreen({super.key, required this.message});
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

String api_token = '';

class _SettingScreenState extends State<SettingScreen> {
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

  storeapi() async {
    api_token = await HelperFunctions.getUserApiKey();

    if (api_token == '') {
      await HelperFunctions.saveUserLoggedIn(false);
      await HelperFunctions.saveUserApiKey("");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
          (route) => false);
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
        title: const Text(
          'Settings',
        ),
      ),
      drawer: appDrawer(context),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // alignment: Alignment.topCenter,
              padding: EdgeInsets.all(5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.person_rounded,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(context.watch<User>().name),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(context.watch<User>().email),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyAccount(
                              message: '',
                            )));
              },
              leading: const Icon(Icons.lock),
              title: const Text("My Account"),
              // trailing: IconButton(
              //   onPressed: () {},
              //   icon: context.read<ThemeProviders>().theme_number == 1
              //       ? Icon(Icons.light_mode)
              //       : Icon(Icons.dark_mode),
              // ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              leading: context.read<ThemeProviders>().theme_number == 1
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
              title: Text(context.read<ThemeProviders>().theme_number == 1
                  ? "Dart Theme "
                  : "Light Theme"),
              // trailing: IconButton(
              //   onPressed: () {},
              //   icon: context.read<ThemeProviders>().theme_number == 1
              //       ? Icon(Icons.light_mode)
              //       : Icon(Icons.dark_mode),
              // ),
              trailing: Switch(
                value: context.read<ThemeProviders>().theme_number == 0
                    ? true
                    : false,
                onChanged: (value) async {
                  await HelperFunctions.saveUserThemeindex(value ? 0 : 1);
                  context.read<ThemeProviders>().updateTheme(value ? 0 : 1);
                },
              ),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              // trailing: IconButton(
              //   onPressed: () {},
              //   icon: context.read<ThemeProviders>().theme_number == 1
              //       ? Icon(Icons.light_mode)
              //       : Icon(Icons.dark_mode),
              // ),
              // trailing: Switch(
              //   value: context.read<ThemeProviders>().theme_number == 0
              //       ? true
              //       : false,
              //   onChanged: (value) {
              //     print(value);
              //     context.read<ThemeProviders>().updateTheme(value ? 0 : 1);
              //   },
              // ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
