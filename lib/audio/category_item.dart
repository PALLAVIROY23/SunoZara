import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:sunozara/constants.dart';
import 'package:sunozara/dashboard.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import '../search.dart';
import '../widget/audio_card.dart';
import '../widget/bottom.dart';
import '../widget/drawer.dart';

class CatItemListScreen extends StatefulWidget {
  dynamic category;
  Function getIndex;
  CatItemListScreen(this.category, {required this.getIndex, super.key});

  @override
  State<CatItemListScreen> createState() => _CatItemListScreenState();
}

class _CatItemListScreenState extends State<CatItemListScreen> {
  dynamic articles = null;
  dynamic cats = [];
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
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

  loadData() {
    print(widget.category);
    print("Hello");
    if (widget.category == null) {
      current_id = "all";
    } else {
      current_id = widget.category["id"].toString();
    }

    loadCachedArticles();
    getArticles();
    loadLang();
  }

  void _onRefresh() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    loadCachedArticles();
    getArticles();
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    if (mounted) {
      setState(() {
        loaded = false;
      });
      loadCachedArticles();
      getArticles();
      loadLang();
    }
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.loadComplete();
  }

  loadLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("languages").toString());

    if (sliderList != 'null') {
      setState(() {
        loaded = true;
        languages = sliderList;
      });

      List<String> optionsx = [];
      for (int i = 0; i < languages.length; i++) {
        optionsx.add(languages[i]["name"]);
      }
      setState(() {
        options = optionsx;
      });
    }
  }

  findLangId() {
    for (int i = 0; i < languages.length; i++) {
      if (i == selected_language) {
        setState(() {
          lang_id = languages[i]["id"].toString();
        });
        break;
      }
    }
  }

  getArticles() {
    // loadCachedArticles();

    ApiService()
        .getAudioByCategory(lang_id, page.toString(), (current_id).toString(),
            _sort_by.toString())
        .then((value) => {artcileData(value)});
  }

  loadCachedArticles() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // dynamic sliderList = jsonDecode(prefs
    //     .getString("cat_audios_${current_id}_${lang_id}_${_sort_by}")
    //     .toString());

    // if (sliderList != 'null') {
    //   setState(() {
    //     loaded = true;
    //     // if (sliderList.length > 0) {
    //     articles = sliderList;
    //     // }
    //   });
    // }
  }

  artcileData(data) async {
    dynamic sliderList = [];
    if (append) {
      for (int i = 0; i < articles.length; i++) {
        sliderList.add(articles[i]);
      }
    }
    // //print(data);
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    if (loading) {
      // Navigator.pop(dialogContext);
    }
    setState(() {
      loaded = true;
      cats = data['cats'];
      articles = sliderList;
      loading = false;
    });

    for (int i = 0; i < articles.length; i++) {
      print(articles[i]["duration"]);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "cat_audios_${widget.category == null ? 'all' : widget.category["id"]}_${lang_id}_${_sort_by}",
        jsonEncode(articles));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // canPop: true,

        onWillPop: () {
          setState(() {
            widget.getIndex(0);
          });
          // Navigator.pushReplacement(
          //     context,
          //     PageTransition(
          //         type: PageTransitionType.leftToRight,
          //         alignment: Alignment.bottomCenter,
          //         child: DashboardTabScreen(0)));
          return Future<bool>.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          drawer: DrawerWidget(),
          appBar: AppBar(
            backgroundColor: THEME_BLACK,
            foregroundColor: Colors.white,
            // leading: BackButton(
            //   onPressed: () {
            //     //print("back Pressed");
            //     setState(() {
            //       widget.getIndex(0);
            //     });
            //   },
            // ),
            title: Text(
              'Find Audiobook',
              style: GoogleFonts.roboto(),
            ),
            automaticallyImplyLeading: true,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          alignment: Alignment.bottomCenter,
                          child: SearchScreen()));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search),
                ),
              )
            ],
          ),
          // bottomNavigationBar: BottomWidget(1),
          body: NotificationListener<ScrollUpdateNotification>(
            child: SmartRefresher(
                enablePullDown: true,
                enableTwoLevel: false,
                // enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: Colors.redAccent,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
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
                                  width: MediaQuery.of(context).size.width - 20,
                                  lineType: ContentLineType.threeLines,
                                ),
                              ],
                            ),
                          )),
                    }
                  },
                  if (loaded) ...{
                    if (cats.length > 0) ...{
                      Container(
                        height: 30,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            InkWell(
                                overlayColor: MaterialStatePropertyAll(
                                    Colors.transparent),
                                onTap: () {
                                  setState(() {
                                    current_id = "all";
                                    loaded = false;
                                    append = false;
                                    page = 1;
                                  });
                                  getArticles();
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: current_id == 'all'
                                          ? Colors.redAccent
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Text(
                                    "All",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )),
                            for (int i = 0; i < cats.length; i++) ...{
                              if (cats[i]['audios_count'] > 0) ...{
                                InkWell(
                                    overlayColor: MaterialStatePropertyAll(
                                        Colors.transparent),
                                    onTap: () {
                                      setState(() {
                                        current_id = cats[i]["id"].toString();
                                        loaded = false;
                                        append = false;
                                        page = 1;
                                      });
                                      //print(current_id);
                                      getArticles();
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: current_id ==
                                                  cats[i]["id"].toString()
                                              ? Colors.redAccent
                                              : Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        cats[i]["name"].toString(),
                                        style: GoogleFonts.roboto(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ))
                              }
                            }
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    },
                    if (articles != null) ...{
                      if (articles.length > 0) ...{
                        for (int i = 0; i < articles.length; i++) ...{
                          AudioCardHorizontalWidget(
                            articles[i],
                            "category",
                          )
                        },
                        if (loading) ...{
                          Container(
                            margin: EdgeInsets.only(bottom: 50),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                        }
                      } else ...{
                        Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                              ),
                              Image.asset(
                                "assets/404.png",
                                width: 150,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Audiobook not found",
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        )
                      }
                    } else ...{
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
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    lineType: ContentLineType.threeLines,
                                  ),
                                ],
                              ),
                            )),
                      }
                    }
                  }
                ])),
            onNotification: (notification) {
              //How many pixels scrolled from pervious frame
              if (notification.metrics.atEdge) {
                if (notification.metrics.pixels == 0) {
                  //print('At top');
                } else {
                  // ajaxLoader();
                  setState(() {
                    page += 1;
                    append = true;
                    loading = true;
                  });
                  getArticles();
                }
              }
              return false;
            },
          ),
        ));
  }
}
