import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/author/author.dart';
import 'package:sunozara/placeholders.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api.dart';
import '../api/api_constant.dart';
import '../brwoser.dart';
import '../widget/bottom.dart';
// import 'package:flutter_inappwebview/src/types.dart';
// import 'package:flutter_inappwebview/src/in_app_browser/in_app_browser_options.dart';

class ArticleDetailScreen extends StatefulWidget {
  dynamic article;
  ArticleDetailScreen(this.article, {super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  dynamic articles = [];
  String views = "0";
  bool articlesLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getArticles();
  }

  getArticles() {
    //print(widget.article['description']);
    setState(() {
      views = widget.article["view_count"].toString();
    });
    loadRelated();
  }

  loadRelated() {
    ApiService()
        .getRelatedArtciles(widget.article["id"].toString())
        .then((value) => {artcileData(value)});
  }

  artcileData(data) async {
    dynamic sliderList = [];
    setState(() {
      views = data["views"].toString();
    });
    for (int i = 0; i < data['data'].length; i++) {
      sliderList.add(data['data'][i]);
    }
    setState(() {
      articles = sliderList;
      articlesLoaded = true;
    });
    // //print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomWidget(0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottomOpacity: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        title: Text("Article"),
      ),
      body: ListView(
        children: [
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              "Published On:   " + widget.article["published_on"].toString(),
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
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Container(
              child: CachedNetworkImage(
                imageUrl: ApiConstants.storagePATH +
                    "/image-manager/" +
                    widget.article["image"].toString(),
                imageBuilder: (context, imageProvider) => Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
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
                                child: AuthorProfileScreen(
                                    widget.article["user"]["id"].toString())));
                      },
                      child: Container(
                        child: Text(
                          "Author: " +
                              widget.article["user"]["name"].toString(),
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      )),
                  Container(
                    child: Text(
                      "Views: " + views.toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 10.h,
          ),
          Divider(color: Colors.white.withOpacity(0.2)),
          SizedBox(
            height: 10.h,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: HtmlWidget(
                widget.article["description"].toString(),
                onTapUrl: (url) {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          alignment: Alignment.bottomCenter,
                          child: MyBrowser(url)));
                  return true;
                },
                textStyle:
                    GoogleFonts.roboto(color: Colors.white, fontSize: 13.sp),
              )),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              "Related Articles",
              style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
          ),
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
                                      type: PageTransitionType.leftToRight,
                                      alignment: Alignment.bottomCenter,
                                      child: ArticleDetailScreen(articles[i])));
                            },
                            child: Container(
                              width: 130.w,
                              height: 127.h,
                              margin: EdgeInsets.only(right: 8.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 139.w,
                                    height: 93.h,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConstants.storagePATH +
                                          "/image-manager/" +
                                          articles[i]["image"].toString(),
                                      imageBuilder: (context, imageProvider) =>
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
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              enabled: true,
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child:
                                                    BannerPlaceholder(93, 139),
                                              )),
                                      errorWidget: (context, url, error) =>
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
                                        color: Colors.white,
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
        ],
      ),
    );
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
