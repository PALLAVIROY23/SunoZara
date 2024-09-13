import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/models/artilce.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api.dart';
import '../dashboard.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import '../widget/bottom.dart';
import '../widget/drawer.dart';
import 'add_article_meta.dart';
import 'own_single_article.dart';

class ArticleListSCreen extends StatefulWidget {
  Function getIndex;
  ArticleListSCreen({required this.getIndex, super.key});

  @override
  State<ArticleListSCreen> createState() => _ArticleListSCreenState();
}

class _ArticleListSCreenState extends State<ArticleListSCreen> {
  dynamic audioList = [];
  bool loaded = false;
  bool isStarted = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() {
    // loadCachedSlider();
    ApiService().getMyArticles().then((value) => {favData(value)});
  }

  void _onRefresh() async {
    // monitor network fetch
    //print("Loading");
    loadData();
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //print("Loading");
    loadData();
    if (mounted) {}
  }

  loadCachedSlider() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList =
        jsonDecode(prefs.getString("my_articles_list").toString());

    if (sliderList != 'null') {
      setState(() {
        loaded = true;
        audioList = sliderList;
      });
    }
  }

  favData(data) async {
    setState(() {
      audioList = data["data"];
      loaded = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("my_articles_list", jsonEncode(audioList));
  }

  startArticle() {
    setState(() {
      isStarted = true;
    });
    ApiService().createArticle().then((value) => {arData(value)});
  }

  arData(data) {
    setState(() {
      isStarted = false;
    });

    ArticleModel am = ArticleModel(
        title: "",
        language: null,
        category: null,
        thumb_id: "",
        description: "",
        article_id: data["data"].toString(),
        thumb: "",
        tags: []);

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: AddArticleMetaSCreen(am)));
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: WillPopScope(
            // canPop: true,

            onWillPop: () {
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: DashboardTabScreen(0)));
              return Future<bool>.value(true);
            },
            child: Scaffold(
                backgroundColor: Colors.transparent,
                drawer: DrawerWidget(),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  // leading: BackButton(
                  //   onPressed: () {
                  //     //print("back Pressed");
                  //     setState(() {
                  //       widget.getIndex(0);
                  //     });
                  //   },
                  // ),
                  foregroundColor: Colors.white,
                  title: Text("My Articles"),
                  automaticallyImplyLeading: true,
                ),
                // bottomNavigationBar: BottomWidget(2),
                body: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropHeader(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView(children: [
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
                                    height: 16.h,
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
                    } else ...{
                      InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            startArticle();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => AddArticleMetaSCreen()));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 0.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6)),
                            child: Column(children: [
                              Text(
                                "Share your unique insights and knowledge with the world by writing an article that can inspire, inform, and make a difference",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 12.sp, color: Colors.white),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      backgroundColor: Colors.redAccent,
                                      // minimumSize: Size(88, 36),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16.w),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                      ),
                                    ),
                                    onPressed: () {
                                      startArticle();
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             AddArticleMetaSCreen()));
                                    },
                                    child: Container(
                                      width: 110.w,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Start Writing'),
                                            isStarted
                                                ? Container(
                                                    height: 20.h,
                                                    width: 20.w,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    "assets/article.png",
                                                    height: 20.h,
                                                  )
                                          ]),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                          )),
                      SizedBox(
                        height: 5.h,
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      if (audioList.length > 0) ...{
                        for (int i = 0; i < audioList.length; i++) ...{
                          OwnSingleArticleScreen(
                            audioList[i],
                            deleteStatus: (bool status, String id) {
                              setState(() {
                                // loaded = false;
                              });
                              loadData();
                            },
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.1),
                          )
                        }
                      } else ...{
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              Image.asset(
                                "assets/404.png",
                                width: 150.w,
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                "Articles not found. Start writing by clicking above button",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        )
                      }
                    }
                  ]),
                ))));
  }
}
