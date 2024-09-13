import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chips_choice/chips_choice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/provider/download.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api.dart';
import '../api/api_constant.dart';
import '../placeholders.dart';
import '../widget/audio_card.dart';
import '../widget/audio_card_hr_dl.dart';
import '../widget/bottom.dart';
import 'package:path_provider/path_provider.dart';

class MyDownloadListScreen extends StatefulWidget {
  MyDownloadListScreen({super.key});

  @override
  State<MyDownloadListScreen> createState() => _MyDownloadListScreenState();
}

class _MyDownloadListScreenState extends State<MyDownloadListScreen> {
  dynamic articles = null;
  dynamic cats = [];
  dynamic downloadList = [];
  bool loaded = false;
  bool loading = false;
  late BuildContext dialogContext;
  dynamic languages = [];
  int selected_language = 0;
  String lang_id = "0";
  List<String> options = [];
  int page = 1;
  bool append = false;
  String _sort_by = "by_date_asc";
  ScrollController _scrollController = ScrollController();
  String current_id = "all";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    // TODO: implement initState
    // context.read<DownloadProvider>().dispose();
    _timer?.cancel();
    super.dispose();
  }

  checkStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();
    List<String> dl = context.read<DownloadProvider>().downloaginList;
    context.read<DownloadProvider>().addListener(() {
      setState(() {
        dl = context.read<DownloadProvider>().downloaginList;
      });
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      String? downloadingList = prefs.getString("downloadingList");

      if (downloadingList == null) {
        for (int i = 0; i < downloadList.length; i++) {
          setst(i, false);
        }
      } else {
        // List<String> dl = List<String>.from(jsonDecode(downloadingList));

        if (dl.length > 0) {
          for (int i = 0; i < downloadList.length; i++) {
            bool found = false;

            for (int j = 0; j < downloadList[i]['episodes_items'].length; j++) {
              if (dl
                  .contains(downloadList[i]['episodes_items'][j].toString())) {
                found = true;
                print("found");
              }
            }
            if (!found) {
              setst(i, false);
            } else {
              setst(i, true);
            }
          }
        } else {
          for (int i = 0; i < downloadList.length; i++) {
            setst(i, false);
          }
        }
      }
    });
  }

  setst(int index, bool s) {
    setState(() {
      downloadList[index]['dl_status'] = s;
    });
  }

  ajaxLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.redAccent.withOpacity(0.1),
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              height: 100,
              child: Center(
                // padding: EdgeInsets.all(15),
                child: Stack(children: [
                  Positioned(
                      top: 15,
                      right: 18,
                      child: Image.asset(
                        "assets/icon.png",
                        height: 50,
                      )),
                  LoadingAnimationWidget.discreteCircle(
                      color: Colors.redAccent,
                      size: 80,
                      secondRingColor: Colors.white,
                      thirdRingColor: Colors.white)
                ]),
              ),
            ));
      },
    );
  }

  void _onRefresh() async {
    setState(() {
      loaded = false;
    });
    loadData();
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    setState(() {
      loaded = false;
    });
    loadData();

    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  loadDownloadFronServer() {
    ApiService().getAudioDownload().then((value) {
      dlList(value);
    }).onError((error, stackTrace) {
      lep();
    });
  }

  dlList(vl) async {
    dynamic data = vl["data"];
    setState(() {
      downloadList = data;
      loaded = true;
    });
    dynamic dlList = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();
    for (int i = 0; i < data.length; i++) {
      // setst(i, false);
      dlList.add(data[i]["id"].toString());
      prefs.setString("audio_info_${data[i]["id"]}", jsonEncode(data[i]));

      for (int j = 0; j < data[i]["episodes"].length; j++) {
        bool? al = prefs.getBool(
            "download_id_${data[i]["episodes"][j]["files"]["id"].toString()}_${uid}");
        if (al == null || al == false) {
          String url = ApiConstants.storagePATH +
              "/episodes/" +
              data[i]["episodes"][j]["files"]["audio_file"].toString();
          String? downloadingList = prefs.getString("downloadingList");
          List<String> dl = [];
          if (downloadingList != null) {
            dl = List<String>.from(jsonDecode(downloadingList));
          }
          if (dl.length == 0) {
            downloadFile(
                url,
                data[i]["episodes"][j]["files"]["id"].toString() + ".mp3",
                data[i]["episodes"][j]["files"]["id"].toString(),
                data[i]["id"].toString());
          }
        }
      }
    }

    checkStatus();
    prefs.setString("downloadList_${uid}", jsonEncode(dlList));
  }

  removeDownload(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();

    dynamic audio_info = jsonDecode(prefs.getString("audio_info_${audio_id}")!);

    // print(audio_info);
    for (int j = 0; j < audio_info["episodes"].length; j++) {
      prefs.remove(
          "download_id_${audio_info["episodes"][j]["files"]["id"].toString()}_${uid}");

      prefs.remove(
          "file_id_${audio_info["episodes"][j]["files"]["id"].toString()}_${uid}");
    }
  }

  Future<void> downloadFile(
      String url, String filename, String id, String aid) async {
    Dio dio = Dio();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("user_id").toString();
    String? downloadList_str = prefs.getString("downloadList_${uid}");
    dynamic downloadListx = [];
    if (downloadList_str != null) {
      downloadListx = jsonDecode(downloadList_str);
      if (!downloadListx.contains(aid)) {
        downloadListx.add(aid);
      }
    } else {
      downloadListx.add(aid);
    }
    prefs.setString("downloadList_${uid}", jsonEncode(downloadListx));
    //print("dlist");
    //print(downloadList_str);

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = "${appDocDir.path}/$filename";
      prefs.setBool("download_id_${id}_${uid}", true);
      prefs.setString("file_id_${id}_${uid}", savePath);

      print("download_id_${id}_${uid}");
      print("dddxxxd");

      Response response = await dio.download(url, savePath,
          onReceiveProgress: (received, total) {});

      if (response.statusCode == 200) {
        ////print('File downloaded successfully!');

        // if (downloadcount == episodes.length) {

        // Fluttertoast.showToast(msg: "Download completed");

        // }
      } else {
        ////print('Failed to download file.');
      }
    } catch (e) {
      ////print('Error downloading file: $e');
    }
  }

  lep() {}

  loadData() async {
    loadDownloadFronServer();
    // if (widget.category == null) {
    //   current_id = "all";
    // } else {
    //   current_id = widget.category["id"].toString();
    // }

    // loadCachedArticles();
    // getArticles();
    // // loadLang();
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String uid = prefs.getString("user_id").toString();
    // String? downloadList_str = prefs.getString("downloadList_${uid}");
    // dynamic downloadListIds = [];
    // if (downloadList_str != null) {
    //   downloadListIds = jsonDecode(downloadList_str);
    // }
    // // downloadListIds = downloadListIds.reverse();
    // setState(() {
    //   downloadList = [];
    // });
    // for (int i = 0; i < downloadListIds.length; i++) {
    //   String? data_s = prefs.getString("audio_info_${downloadListIds[i]}");

    //   if (data_s != null) {
    //     dynamic data = jsonDecode(data_s);
    //     setState(() {
    //       downloadList.add(data);
    //     });
    //   }
    // }
    //print(downloadList);

    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: THEME_BLACK,
          foregroundColor: Colors.white,
          title: Text(
            'My Downloads',
            style: GoogleFonts.roboto(),
          ),
          automaticallyImplyLeading: true,
        ),
        bottomNavigationBar: BottomWidget(5),
        body: SmartRefresher(
          enablePullDown: true,
          enableTwoLevel: false,
          // enablePullUp: true,
          header: WaterDropHeader(
            waterDropColor: Colors.redAccent,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: NotificationListener<ScrollUpdateNotification>(
            child: ListView(controller: _scrollController, children: [
              if (!loaded) ...{
                for (int i = 0; i < 5; i++) ...{
                  Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            ContentPlaceholder(
                              width: MediaQuery.of(context).size.width * 0.9,
                              lineType: ContentLineType.threeLines,
                            ),
                          ],
                        ),
                      )),
                }
              },
              if (loaded) ...{
                if (downloadList != null) ...{
                  if (downloadList.length > 0) ...{
                    for (int i = downloadList.length - 1; i >= 0; i--) ...{
                      AudioCardHorizontalDownloadWidget(
                        downloadList[i],
                        "downloads",
                        canReload: (bool cr, String id) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String uid = prefs.getString("user_id").toString();
                          removeDownload(id.toString());
                          String? downloadList_str =
                              prefs.getString("downloadList_${uid}");
                          dynamic downloadListIds = [];
                          dynamic downloadListIdsx = [];
                          if (downloadList_str != null) {
                            downloadListIds = jsonDecode(downloadList_str);
                          }
                          // downloadListIds = downloadListIds.reverse();
                          setState(() {
                            downloadList = [];
                          });
                          for (int i = 0; i < downloadListIds.length; i++) {
                            if (downloadListIds[i].toString() != id) {
                              String? data_s = prefs.getString(
                                  "audio_info_${downloadListIds[i]}");

                              // downloadListIds[i].toString() != id
                              if (data_s != null) {
                                dynamic data = jsonDecode(data_s);
                                setState(() {
                                  downloadList.add(data);
                                  downloadListIdsx.add(downloadListIds[i]);
                                });
                              }
                            }
                          }

                          prefs.setString("downloadList_${uid}",
                              jsonEncode(downloadListIdsx));
                          loadData();
                        },
                      )
                    },
                    if (loading) ...{
                      Container(
                        margin: EdgeInsets.only(bottom: 50),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    }
                  } else ...{
                    Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          Image.asset(
                            "assets/404.png",
                            width: 150,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "No items in downloads",
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    )
                  }
                } else
                  ...{}
              } else ...{
                for (int i = 0; i < 5; i++) ...{}
              }
            ]),
            onNotification: (notification) {
              //How many pixels scrolled from pervious frame
              if (notification.metrics.atEdge) {
                if (notification.metrics.pixels == 0) {
                  //print('At top');
                } else {
                  if (loaded) {
                    ajaxLoader();
                    setState(() {
                      page += 1;
                      append = true;
                      loading = true;
                    });
                  }
                }
              }
              return true;
            },
          ),
        ));
  }
}
