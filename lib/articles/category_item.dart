import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chips_choice/chips_choice.dart';
import '../placeholders.dart';
import '../search.dart';
import '../select_lang.dart';
import '../widget/audio_card.dart';
import '../widget/bottom.dart';
import 'card.dart';
import 'filter.dart';

class ArticleCategoryItemScreen extends StatefulWidget {
  dynamic category;
  ArticleCategoryItemScreen(this.category, {super.key});

  @override
  State<ArticleCategoryItemScreen> createState() =>
      _ArticleCategoryItemScreenState();
}

class _ArticleCategoryItemScreenState extends State<ArticleCategoryItemScreen> {
  dynamic articles = [];
  dynamic cats = [];
  bool loaded = false;
  dynamic languages = [];
  int selected_language = 0;
  String lang_id = "0";
  List<String> options = [];
  int page = 1;
  bool append = false;
  String _sort_by = "by_popular";
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String current_id = "all";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() {
    if (widget.category == null) {
      current_id = "all";
    } else {
      current_id = current_id.toString();
    }
    loadCachedArticles();
    getArticles();
    loadLang();
  }

  void _onRefresh() async {
    // monitor network fetch
    //print("Loading");

    loadCachedArticles();
    getArticles();
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    //print("Loading");

    if (mounted) {
      loadCachedArticles();
      getArticles();
    }
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
    loadCachedArticles();
    ApiService()
        .getArticleByCategory(lang_id, page.toString(), current_id.toString(),
            _sort_by.toString())
        .then((value) => {artcileData(value)});
  }

  loadCachedArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs
        .getString("cat_articles_${current_id}_${lang_id}_${_sort_by}")
        .toString());

    if (sliderList != 'null') {
      setState(() {
        loaded = true;
        articles = sliderList;
      });
    }
  }

  artcileData(data) async {
    dynamic sliderList = [];
    if (append) {
      for (int i = 0; i < articles.length; i++) {
        sliderList.add(articles[i]);
      }
    }
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    setState(() {
      loaded = true;
      cats = data['cats'];
      articles = sliderList;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cat_articles_${current_id}_${lang_id}_${_sort_by}",
        jsonEncode(articles));
  }

  filter() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return FilterArticleScreen(
          _sort_by,
          getSort: (String sort) {
            setState(() {
              _sort_by = sort;
              loaded = false;
            });
            getArticles();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          filter();
        },
        child: Icon(
          Icons.filter_list,
          color: Colors.white,
          size: 29,
        ),
        isExtended: false,
        backgroundColor: const Color.fromARGB(255, 32, 31, 31),
        tooltip: 'Filter Article',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: THEME_BLACK,
        foregroundColor: Colors.white,
        title: Text(widget.category != null
            ? widget.category["name"].toString()
            : 'Find Articles'),
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
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Icon(Icons.search),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomWidget(2),
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
                    height: 30.h,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        InkWell(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent),
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
                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                  color: current_id == 'all'
                                      ? Colors.redAccent
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                "All",
                                style: GoogleFonts.roboto(
                                    color: Colors.white, fontSize: 12.sp),
                              ),
                            )),
                        for (int i = 0; i < cats.length; i++) ...{
                          // if (cats[i]['articles_count'] > 0) ...{
                          InkWell(
                              overlayColor:
                                  MaterialStatePropertyAll(Colors.transparent),
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
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                    color:
                                        current_id == cats[i]["id"].toString()
                                            ? Colors.redAccent
                                            : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  cats[i]["name"].toString(),
                                  style: GoogleFonts.roboto(
                                      color: Colors.white, fontSize: 12.sp),
                                ),
                              ))
                        }
                        // }
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                },
                if (articles != null) ...{
                  if (articles.length > 0) ...{
                    for (int i = 0; i < articles.length; i++) ...{
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ArticleCardWidget(articles[i], "category"),
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
                            width: 150.w,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Articles not found",
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
                                height: 16.h,
                              ),
                              ContentPlaceholder(
                                width: MediaQuery.of(context).size.width - 20,
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
              setState(() {
                page += 1;
                append = true;
                getArticles();
              });
            }
          }
          return true;
        },
      ),
    );
  }
}
