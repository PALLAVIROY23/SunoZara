import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/author/author.dart';
import 'package:sunozara/placeholders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api.dart';
import '../api/api_constant.dart';
import '../audio/review.dart';
import '../brwoser.dart';
import '../constants.dart';
import '../dashboard_tab.dart';
import '../search.dart';
import '../widget/bottom.dart';
import 'package:intl/intl.dart';

import 'category_item.dart';
import 'edit_review_article.dart';
import 'review_article.dart';
// import 'package:flutter_inappwebview/src/types.dart';
// import 'package:flutter_inappwebview/src/in_app_browser/in_app_browser_options.dart';

class ArticleDetailScreen extends StatefulWidget {
  dynamic article;
  String source;
  String? keyd;
  ArticleDetailScreen(this.article, this.source, {this.keyd = null, super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  dynamic articles = [];
  String views = "0";
  bool deleting = false;
  dynamic myrate;
  dynamic ratingList = [];
  dynamic yourRating;
  bool articlesLoaded = false;
  bool loaded = true;
  bool rloaded = false;
  Timer? _timer;
  bool is_owned = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    getArticles();

    getReviews();
  }

  editReview(dynamic mr) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: EditReviewArticleScreen(
              widget.article,
              mr,
              isReviewed: (bool xr) {
                if (xr) {
                  getReviews();
                }
              },
            )));
  }

  delItem(dynamic mr) {
    setState(() {
      deleting = true;
    });
    ApiService()
        .delpostArticleReview(mr["id"].toString())
        .then((value) => confDel(value))
        .onError((error, stackTrace) => lepd());
  }

  lepd() {
    setState(() {
      deleting = false;
    });
    Fluttertoast.showToast(msg: "Unable to delete your review.");
  }

  confDel(d) {
    setState(() {
      deleting = false;
    });
    getReviews();

    Fluttertoast.showToast(msg: "Your review has been deleted");
    Navigator.pop(context);
  }

  deleteReview(dynamic mr) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 350.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            color: HexColor("16181f"),
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: Colors.white),
                    )
                  ],
                ),
                Icon(MdiIcons.trashCan,
                    size: 50, color: Colors.redAccent.withOpacity(0.8)),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Delete your review?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Once you delete your reviews, they cannot be retrieved.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      deleting
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              value: 10,
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 1.0],
                                    colors: [
                                      Colors.redAccent.shade400,
                                      Colors.blue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 10.h)),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.transparent)),
                                onPressed: () {
                                  if (!deleting) {
                                    setState(
                                      () {
                                        deleting = true;
                                      },
                                    );
                                    delItem(mr);
                                  }
                                },
                                child: Text(
                                  "Delete",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25)),
                          child: TextButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10.h)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.transparent)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getString("user_id").toString();

    if (widget.article["user"]["id"].toString() == user_id) {
      setState(() {
        is_owned = false;
      });
    }
  }

  getReviews() {
    ApiService()
        .getArticleReview(widget.article["id"].toString())
        .then((value) => {rvData(value)});
  }

  rvData(data) {
    setState(() {
      yourRating = data["selfRating"];
      ratingList = data["ratings"];
      myrate = data["myrate"];
      widget.article["ratings"] = data["article_ratings"];
      rloaded = true;
    });
  }

  getArticles() {
    //print(widget.article['description']);
    // print(widget.article["status"]);
    setState(() {
      views = widget.article["view_count"].toString();
    });
    loadRelated();
  }

  @override
  void dispose() {
    /// please do not forget to dispose the controller
    _timer?.cancel();
    super.dispose();
  }

  viewsCount() {
    if (is_owned) {
      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        ApiService()
            .viewsCountArticle(widget.article["id"].toString())
            .then((value) => viewsCountData(value));
      });
    }
  }

  viewsCountData(data) {
    _timer?.cancel();
    print(data);
    setState(() {
      // views = data["views"].toString();
    });
  }

  loadRelated() {
    ApiService()
        .getRelatedArtciles(widget.article["id"].toString())
        .then((value) => {artcileData(value)})
        .onError((error, stackTrace) => led(error));
  }

  led(error) {
    print(error);
    setState(() {
      loaded = true;
    });
    viewsCount();
  }

  artcileData(data) async {
    dynamic sliderList = [];
    // setState(() {
    //   views = data["views"].toString();
    // });
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    setState(() {
      articles = sliderList;
      articlesLoaded = true;
      loaded = true;
    });
    viewsCount();
    // //print(data);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (widget.source == "dashboard") {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.leftToRight,
                    alignment: Alignment.bottomCenter,
                    child: DashboardTabScreen(0)));
          }

          if (widget.source == "category") {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.leftToRight,
                    alignment: Alignment.bottomCenter,
                    child: ArticleCategoryItemScreen(null)));
          }

          if (widget.source == "search") {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.leftToRight,
                    alignment: Alignment.bottomCenter,
                    child: SearchScreen(
                      skey: widget.keyd == null ? "" : widget.keyd!,
                    )));
          }
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomWidget(
            2,
            mode: "light",
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottomOpacity: 0,
            foregroundColor: Colors.black,
            automaticallyImplyLeading: true,
            centerTitle: true,
            elevation: 0,
            title: Text("Article"),
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
          body: ListView(
            children: [
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
                              width: MediaQuery.of(context).size.width * 0.9,
                              lineType: ContentLineType.threeLines,
                            ),
                          ],
                        ),
                      )),
                }
              } else ...{
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Text(
                    widget.article["title"].toString(),
                    style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                widget.article['status'].toString() == "Published"
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Text(
                          "Published On:   " +
                              widget.article["published_on"].toString(),
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Text(
                          widget.article['status'].toString() +
                              ": " +
                              widget.article["published_on"].toString(),
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.storagePATH +
                          "/image-manager/" +
                          widget.article["image"].toString(),
                      // imageBuilder: (context, imageProvider) => Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 150,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     image: DecorationImage(
                      //         image: imageProvider, fit: BoxFit.cover),
                      //   ),
                      // ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: AuthorProfileScreen(widget
                                          .article["user"]["id"]
                                          .toString())));
                            },
                            child: Container(
                              child: Text(
                                "Author: " +
                                    widget.article["user"]["name"].toString(),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                        is_owned
                            ? Container(
                                child: Text(
                                  "Views: " + views.toString(),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : SizedBox(),
                      ],
                    )),
                SizedBox(
                  height: 10.h,
                ),
                Divider(
                  color: Colors.black.withOpacity(0.1),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: HtmlWidget(widget.article["description"].toString(),
                        onTapUrl: (url) {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRight,
                              alignment: Alignment.bottomCenter,
                              child: MyBrowser(url)));
                      return true;
                    })),
                if (articlesLoaded) ...{
                  if (articles.length > 0) ...{
                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(
                        "Related Articles",
                        style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  },
                },
                SizedBox(
                  height: 10.h,
                ),
                !articlesLoaded
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 140.h,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (int i = 0; i < articles.length; i++) ...{
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            alignment: Alignment.bottomCenter,
                                            child: ArticleDetailScreen(
                                                articles[i], widget.source)));
                                  },
                                  child: Container(
                                    width: 130.w,
                                    height: 127.h,
                                    margin: EdgeInsets.only(right: 8.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 139.w,
                                          height: 93.h,
                                          child: CachedNetworkImage(
                                            imageUrl: ApiConstants.storagePATH +
                                                "/image-manager/" +
                                                articles[i]["image"].toString(),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 139.w,
                                              height: 93.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    enabled: true,
                                                    child:
                                                        SingleChildScrollView(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      child: BannerPlaceholder(
                                                          93, 139),
                                                    )),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.image),
                                          ),
                                        ),
                                         SizedBox(height: 4.h),
                                        SizedBox(
                                          width: 151.w,
                                          child: Text(
                                            articles[i]["title"].toString(),
                                            maxLines: 3,
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              height: 0.h,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            }
                          ],
                        ),
                      )
              },
              if (rloaded & loaded & is_owned) ...{
                SizedBox(
                  height: 10.h,
                ),
                Divider(),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Text(
                    "Article Ratings & Reviews",
                    style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                      double.parse(widget.article["ratings"]
                                              .toString())
                                          .toStringAsFixed(1)
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold)),
                                  Text(" / ",
                                      style: GoogleFonts.poppins(
                                          color:
                                              Colors.black.withOpacity(0.6))),
                                  Text(
                                    "5.0",
                                    style: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.6)),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          child: RatingBar.builder(
                            initialRating: double.parse(
                                widget.article["ratings"].toString()),
                            minRating: double.parse(
                                widget.article["ratings"].toString()),
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemSize: 25,
                            unratedColor: Colors.grey,
                            // itemCount: 5,
                            // glow: true,
                            // glowColor: Colors.amber,
                            glow: false,
                            ignoreGestures: true,
                            glowRadius: 5,
                            maxRating: double.parse(
                                widget.article["ratings"].toString()),
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0.w),
                            itemBuilder: (context, _) => Icon(
                              MdiIcons.star,
                              size: 15,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              //print(rating);
                            },
                          ),
                        )
                      ],
                    )),
                InkWell(
                    onTap: () {
                      if (yourRating == null) {
                        // Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: ReviewArticleScreen(
                                  widget.article,
                                  isReviewed: (bool rv) {
                                    if (rv) {
                                      getReviews();
                                    }
                                  },
                                )));
                      }
                    },
                    child: Container(
                        decoration:
                            BoxDecoration(color: THEME_BLACK.withOpacity(0.5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Text(
                              "You Rated",
                              style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500),
                            )),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.w),
                              child: RatingBar.builder(
                                initialRating: yourRating != null
                                    ? double.parse(
                                        yourRating["rating"].toString())
                                    : 0,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemSize: 25,
                                ignoreGestures: true,
                                unratedColor: Colors.grey,
                                // itemCount: 5,
                                // glow: true,
                                // glowColor: Colors.amber,
                                glow: false,
                                glowRadius: 5,
                                maxRating: yourRating != null
                                    ? double.parse(
                                        yourRating["rating"].toString())
                                    : 0,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0.w
                                    ),
                                itemBuilder: (context, _) => Icon(
                                  MdiIcons.star,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  //print(rating);
                                },
                              ),
                            )
                          ],
                        ))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(children: [
                    Text(
                      "Reviews",
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 16.sp),
                    )
                  ]),
                ),
                if (myrate != null) ...{
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            editReview(myrate);
                          },
                          child: Icon(MdiIcons.pencil,
                              size: 25, color: Colors.black),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        InkWell(
                          onTap: () {
                            deleteReview(myrate);
                          },
                          child: Icon(MdiIcons.trashCan,
                              size: 25,
                              color: Colors.redAccent.withOpacity(0.8)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(children: [
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(ApiConstants.storagePATH +
                                    "/author/" +
                                    myrate["user"]["profile_photo"]
                                        .toString()))),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        myrate["user"]["name"].toString(),
                        style: GoogleFonts.poppins(color: Colors.black),
                      )
                    ]),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                initialRating:
                                    double.parse(myrate["rating"].toString()),
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemSize: 20,
                                ignoreGestures: true,
                                unratedColor: Colors.grey,
                                glow: false,
                                glowRadius: 5,
                                maxRating:
                                    double.parse(myrate["rating"].toString()),
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 2.0.w),
                                itemBuilder: (context, _) => Icon(
                                  MdiIcons.star,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  //print(rating);
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Text(
                            DateFormat.yMMMMd().format(DateTime.parse(
                                myrate["updated_at"].toString())),
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 12.sp),
                          ),
                        )
                      ]),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      myrate["comment"].toString(),
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                    height: 2.h,
                    decoration:
                        BoxDecoration(color: Colors.black.withOpacity(0.5)),
                  )
                },
                for (int i = 0; i < ratingList.length; i++) ...{
                  if (ratingList[i]["user"] != null) ...{
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Row(children: [
                        Container(
                          height: 40.w,
                          width: 40.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(ApiConstants.storagePATH +
                                      "/author/" +
                                      ratingList[i]["user"]["profile_photo"]
                                          .toString()))),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          ratingList[i]["user"]["name"].toString(),
                          style: GoogleFonts.poppins(color: Colors.black),
                        )
                      ]),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBar.builder(
                                  initialRating: double.parse(
                                      ratingList[i]["rating"].toString()),
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemSize: 20,
                                  ignoreGestures: true,
                                  unratedColor: Colors.grey,
                                  glow: false,
                                  glowRadius: 5,
                                  maxRating: double.parse(
                                      ratingList[i]["rating"].toString()),
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 2.0.w),
                                  itemBuilder: (context, _) => Icon(
                                    MdiIcons.star,
                                    size: 15,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    //print(rating);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Text(
                              DateFormat.yMMMMd().format(DateTime.parse(
                                  ratingList[i]["created_at"].toString())),
                              style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 12.sp),
                            ),
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        ratingList[i]["comment"].toString(),
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                      height: 2.h,
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    )
                  }
                },
                SizedBox(
                  height: 50.h,
                )
              }
            ],
          ),
        ));
  }

  launchUrl(String url) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: MyBrowser(url)));
  }
}
