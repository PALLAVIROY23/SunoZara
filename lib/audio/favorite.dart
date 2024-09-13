import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../dashboard.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import '../widget/audio_card_horizontal.dart';
import '../widget/bottom.dart';
import '../widget/drawer.dart';

class MyFavAudioList extends StatefulWidget {
  Function getIndex;
  MyFavAudioList({required this.getIndex, super.key});

  @override
  State<MyFavAudioList> createState() => _MyFavAudioListState();
}

class _MyFavAudioListState extends State<MyFavAudioList> {
  dynamic audioList = [];
  bool loaded = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void _onRefresh() async {
    // monitor network fetch
    //print("Loading");
    loadData();
    await Future.delayed(Duration(milliseconds: 2000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //print("Loading");

    if (mounted) {
      loadData();
    }
    await Future.delayed(Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  loadData() {
    loadCachedSlider();
    ApiService()
        .getFavAudioList()
        .then((value) => {favData(value)})
        .onError((error, stackTrace) => led());
  }

  led() {
    setState(() {
      loaded = true;
    });
  }

  loadCachedSlider() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList =
        jsonDecode(prefs.getString("favorite_list").toString());

    if (sliderList != 'null') {
      setState(() {
        // loaded = true;
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
    prefs.setString("favorite_list", jsonEncode(audioList));
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
              Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: DashboardTabScreen(0)),
                  (route) => false);
              return Future<bool>.value(true);
            },
            child: Scaffold(
                // bottomNavigationBar: BottomWidget(4),
                backgroundColor: Colors.transparent,
                drawer: DrawerWidget(),
                appBar: AppBar(
                  automaticallyImplyLeading: true,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  // leading: BackButton(
                  //   onPressed: () {
                  //     //print("back Pressed");
                  //     setState(() {
                  //       widget.getIndex(0);
                  //     });
                  //   },
                  // ),
                  title: Text(
                    "My Favorites",
                    style: GoogleFonts.poppins(),
                  ),
                ),
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
                                    height: 16,
                                  ),
                                  ContentPlaceholder(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    lineType: ContentLineType.threeLines,
                                  ),
                                ],
                              ),
                            )),
                      }
                    },
                    if (loaded) ...{
                      if (audioList != null) ...{
                        if (audioList.length > 0) ...{
                          for (int i = 0; i < audioList.length; i++) ...{
                            AudioCardHorizontalWidget(audioList[i], "favorite")
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
                                  "No items into favorite list",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
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
                                "No items into favorite list",
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
