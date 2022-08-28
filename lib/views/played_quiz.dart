import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:quiz_earn/constant/constant.dart';
import 'package:quiz_earn/helper/helper.dart';
import 'package:quiz_earn/views/signin.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ndialog/ndialog.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:open_file/open_file.dart';
import '../widget/drawer.dart';

class PlayedQuiz extends StatefulWidget {
  @override
  _PlayedQuizState createState() => _PlayedQuizState();
}

class _PlayedQuizState extends State<PlayedQuiz> {
  TextEditingController searchQuiz = TextEditingController();
  List PlayedQuizGet = [];

  late String api_token;

  late Future getDataFun;
  final formKey = GlobalKey<FormState>();

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
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
    WidgetsFlutterBinding.ensureInitialized();

    FlutterDownloader.registerCallback(downloadCallback);
    storeapi();

    getDataFun = getData();

    super.initState();
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

//Start PDf viewer link code
  double progress = 0;
  bool didDownloadPDF = false;
  String progressString = 'File has not been downloaded yet.';

  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString =
            '✅ File has finished downloading. Try opening the file.';
        didDownloadPDF = true;
      } else {
        progressString = 'Download progress: ' +
            (progress * 100).toStringAsFixed(0) +
            '% done.';
      }
    });
  }

  Future download(Dio dio, String url, String savePath) async {
    try {
      var api = await HelperFunctions.getUserApiKey();
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            headers: {
              'Authorization': 'Bearer $api',
              "X-Requested-With": "XMLHttpRequest"
            },
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await file.close();

      // Here, you're catching an error and printing it. For production
      // apps, you should display the warning to the user and give them a
      // way to restart the download.
    } catch (e) {
      print(e);
    }
  }
//End PDf viewer link code

  getData() async {
    var api = await HelperFunctions.getUserApiKey();

    if (api != '') {
      String url = base_url + "/api/result/getquiz/";

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
              MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false);
        } else {
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
            MaterialPageRoute(builder: (context) => SignIn()),
            (route) => false);
      } else {
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

  Future<Null> _handleRefresh() async {
    setState(() {
      getDataFun = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Results',
          style: TextStyle(color: Colors.blueAccent, fontSize: 22),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              NAlertDialog(
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: searchQuiz,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Quiz Name",
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      child: Text("Search"),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);

                          String url = base_url +
                              "/api/result/search/" +
                              searchQuiz.text;
                          setState(() {
                            searchQuiz.text = '';
                            getDataFun = updateData(url);
                          });
                        }
                      }),
                ],
              ).show(context);
            },
            child: Padding(
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
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                Icons.refresh,
              ),
            ),
          ),
        ],
      ),
      drawer: appDrawer(context),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: FutureBuilder(
            future: getDataFun,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
                  List subjectsGet = snapshot.data as List;
                  return ListView.builder(
                      itemCount: subjectsGet.length,
                      itemBuilder: (context, index) {
                        return Container(
                            child: Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 25,
                              color: Colors.grey[500],
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(subjectsGet[index]['title']),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  child:
                                      Text(subjectsGet[index]['description']),
                                )
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () async {
                                try {
                                  ProgressDialog progressDialog =
                                      ProgressDialog(context,
                                          title: Text("Loading..."));
                                  progressDialog.show();
                                  var url = base_url +
                                      "/api/download/result/" +
                                      subjectsGet[index]['id'].toString();

                                  var api =
                                      await HelperFunctions.getUserApiKey();
                                  PDFDocument doc =
                                      await PDFDocument.fromURL(url, headers: {
                                    'Authorization': 'Bearer $api',
                                    "X-Requested-With": "XMLHttpRequest"
                                  });
                                  progressDialog.dismiss();
                                  await Dialog(
                                    child: PDFViewer(
                                      document: doc,
                                      lazyLoad: false,
                                    ),
                                  ).show(super.context);
                                } catch (e) {
                                  await NAlertDialog(
                                    dismissable: false,
                                    dialogStyle:
                                        DialogStyle(titleDivider: true),
                                    title: Text("Opps Something Went Worng!"),
                                    content: Text(
                                        "Please check your connectivity or try Again.."),
                                    actions: <Widget>[
                                      TextButton(
                                          child: Text("Ok"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  ).show(context);
                                }
                              },
                              icon: Icon(
                                Icons.visibility,
                                size: 25,
                                color: Colors.grey[500],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  var url = base_url +
                                      "/api/download/result/" +
                                      subjectsGet[index]['id'].toString();

                                  final status =
                                      await Permission.storage.request();
                                  if (!status.isGranted) {
                                    // ignore: avoid_print

                                  } else {
                                    final exterdir = await getDownloadPath();

                                    final task =
                                        await FlutterDownloader.enqueue(
                                      url: url,
                                      headers: {
                                        'Authorization': 'Bearer $api_token',
                                      },
                                      savedDir: exterdir ??
                                          '/storage/emulated/0/Download',
                                      fileName: 'result.pdf',
                                      saveInPublicStorage: true,
                                    );
                                  }
                                } catch (e) {
                                  await NDialog(
                                    title: Text(
                                        "Opps Something Went Worng! or try again after sometime.."),
                                  ).show(context);
                                }
                              },
                              icon: Icon(
                                Icons.download_sharp,
                                size: 25,
                                color: Colors.grey[500],
                              ),
                            )
                          ],
                        ));
                        return ListTile(
                          onTap: () async {
                            try {
                              var url = base_url +
                                  "/api/download/result/" +
                                  subjectsGet[index]['id'].toString();

                              final status = await Permission.storage.request();
                              if (!status.isGranted) {
                                // ignore: avoid_print

                              } else {
                                final exterdir = await getDownloadPath();
                                final exterdir2 =
                                    await getExternalStorageDirectory();
                                // ignore: unused_local_variable1
                                final task = await FlutterDownloader.enqueue(
                                  url: url,
                                  headers: {
                                    'Authorization': 'Bearer $api_token',
                                  },
                                  savedDir: exterdir == null
                                      ? '/storage/emulated/0/Download'
                                      : exterdir,
                                  fileName: 'result.pdf',
                                  showNotification: true,
                                  openFileFromNotification: true,
                                );
                              }
                            } catch (e) {
                              await NDialog(
                                title: Text(
                                    "Opps Something Went Worng! or try again after sometime.."),
                              ).show(context);
                            }
                          },
                          leading: Icon(Icons.subject),
                          title: Text(subjectsGet[index]['title']),
                          subtitle: Text(subjectsGet[index]['description']),
                          trailing: Icon(
                            Icons.download_outlined,
                            color: Color(0xFF303030),
                            size: 20,
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return Center(
                      child: Text(
                    'No result Found',
                  ));
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
