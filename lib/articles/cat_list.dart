import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api.dart';
import '../api/api_constant.dart';
import '../audio/category_item.dart';
import '../constants.dart';
import '../placeholders.dart';
import 'category_item.dart';

class ArticleCategoryScreen extends StatefulWidget {
  const ArticleCategoryScreen({super.key});

  @override
  State<ArticleCategoryScreen> createState() => _ArticleCategoryScreenState();
}

class _ArticleCategoryScreenState extends State<ArticleCategoryScreen> {
  dynamic categories = [];
  @override
  void initState() {
    super.initState();

    loadData();
    // startMiniPlayer();
  }

  loadData() {
    getCategories();
  }

  getCategories() {
    loadCachedCat();
    ApiService().getAllCategories().then((value) => {catData(value)});
  }

  loadCachedCat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("home_cats").toString());

    if (sliderList != 'null') {
      setState(() {
        categories = sliderList;
      });
    }
  }

  catData(data) async {
    dynamic sliderList = [];
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    setState(() {
      categories = sliderList;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home_cats", jsonEncode(categories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Article Category"),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ListView(
            children: [
              SizedBox(
                height: 20.h,
              ),
              for (int i = 0; i < categories.length; i = i + 4) ...{
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (i < categories.length) ...{
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: ArticleCategoryItemScreen(
                                          categories[i])));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    height: 50.h,
                                    width: 50.w,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/category/" +
                                          categories[i]["image"].toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0.w,
                                        height: 50.0.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              enabled: true,
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child:
                                                    BannerPlaceholder(50, 50),
                                              )),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.image),
                                    ),
                                  ),
                                  Text(
                                    categories[i]["name"].toString(),
                                    style: GoogleFonts.poppins(
                                        color: TEXT_WHITE_SHADE, fontSize: 12.sp),
                                  )
                                ],
                              ),
                            )),
                      },
                      if (i + 1 < categories.length) ...{
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: ArticleCategoryItemScreen(
                                          categories[i + 1])));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    height: 50.h,
                                    width: 50.w,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/category/" +
                                          categories[i + 1]["image"].toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0.w,
                                        height: 50.0.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.image),
                                    ),
                                  ),
                                  Text(
                                    categories[i + 1]["name"].toString(),
                                    style: GoogleFonts.poppins(
                                        color: TEXT_WHITE_SHADE, fontSize: 12.sp),
                                  )
                                ],
                              ),
                            )),
                      },
                      if (i + 2 < categories.length) ...{
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: ArticleCategoryItemScreen(
                                          categories[i + 2])));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    height: 50.h,
                                    width: 50.h,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/category/" +
                                          categories[i + 2]["image"].toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0.w,
                                        height: 50.0.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.image),
                                    ),
                                  ),
                                  Text(
                                    categories[i + 2]["name"].toString(),
                                    style: GoogleFonts.poppins(
                                        color: TEXT_WHITE_SHADE, fontSize: 12.sp),
                                  )
                                ],
                              ),
                            )),
                      },
                      if (i + 3 < categories.length) ...{
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: ArticleCategoryItemScreen(
                                          categories[i + 3])));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    height: 50.h,
                                    width: 50.w,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/category/" +
                                          categories[i + 3]["image"].toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0.w,
                                        height: 50.0.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.image),
                                    ),
                                  ),
                                  Text(
                                    categories[i + 3]["name"].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                    style: GoogleFonts.poppins(
                                        color: TEXT_WHITE_SHADE, fontSize: 12.sp),
                                  )
                                ],
                              ),
                            )),
                      }
                    ],
                  ),
                )
              }
            ],
          )),
    );
  }
}
