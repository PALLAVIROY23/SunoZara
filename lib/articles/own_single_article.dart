import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/models/artilce.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../dashboard_tab.dart';
import '../placeholders.dart';
import 'add_article_meta.dart';
import 'details.dart';
import 'list.dart';

class OwnSingleArticleScreen extends StatefulWidget {
  dynamic article;
  Function deleteStatus;
  OwnSingleArticleScreen(this.article, {required this.deleteStatus, super.key});

  @override
  State<OwnSingleArticleScreen> createState() => _OwnSingleArticleScreenState();
}

class _OwnSingleArticleScreenState extends State<OwnSingleArticleScreen> {
  bool deleting = false;
  Color bcolor = Colors.grey;
  delArt(data, id) {
    setState(() {
      deleting = false;
    });
    Fluttertoast.showToast(msg: data["message"].toString());
    Navigator.pop(context);
    setState(() {
      widget.deleteStatus(true, id);
    });
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.leftToRight,
    //         alignment: Alignment.bottomCenter,
    //         child: DashboardTabScreen(2)));
  }

  delete(String id) {
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
                Icon(
                  MdiIcons.trashCan,
                  size: 50,
                  color: Colors.redAccent,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "Do you want to delete?",
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Your deleted item can not be retrieved.",
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
                                    delete1(id);
                                  }
                                },
                                child: Text(
                                  "Yes Delete",
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

  delete1(String id) {
    setState(() {
      deleting = true;
    });
    ApiService().deleteArticle(id).then((value) => {delArt(value, id)});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bc();
  }

  bc() {
    //print(widget.article['status'].toString().toLowerCase());
    if (widget.article['status'].toString().toLowerCase().trim() ==
        "published") {
      setState(() {
        bcolor = Colors.greenAccent;
      });
    } else if (widget.article['status'].toString().toLowerCase().trim() ==
        "rejected") {
      setState(() {
        bcolor = Colors.redAccent;
      });
    } else if (widget.article['status'].toString().toLowerCase().trim() ==
        "pending") {
      setState(() {
        bcolor = Colors.blueAccent;
      });
    } else {
      setState(() {
        bcolor = Colors.grey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.h,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
          minLeadingWidth: 40.w,
          title: InkWell(
              overlayColor: MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        alignment: Alignment.bottomCenter,
                        child: ArticleDetailScreen(widget.article, "own")));
              },
              child: Text(
                widget.article['title'].toString().trim() == ""
                    ? "No Title[Draft]"
                    : widget.article['title'].toString(),
                maxLines: 2,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.sp),
              )),
          isThreeLine: true,
          trailing: Container(
            width: 60.w,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    List<String> tgx = [];
                    for (int i = 0; i < widget.article["tags"].length; i++) {
                      tgx.add(widget.article["tags"][i]["id"].toString());
                    }
                    ArticleModel ar = ArticleModel(
                      title: widget.article["title"].toString(),
                      language: widget.article["language"] != ""
                          ? widget.article["language"]["id"].toString()
                          : null,
                      category: widget.article["category"] != ""
                          ? widget.article["category"]["id"].toString()
                          : null,
                      thumb_id: widget.article["thumb_id"].toString(),
                      description: widget.article["description"].toString(),
                      article_id: widget.article["id"].toString(),
                      thumb: widget.article["image"].toString(),
                      tags: tgx,
                    );

                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            alignment: Alignment.bottomCenter,
                            child: AddArticleMetaSCreen(ar)));
                  },
                  child: Icon(
                    MdiIcons.pencilCircle,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                InkWell(
                  onTap: () {
                    delete(widget.article["id"].toString());
                  },
                  child: Icon(
                    MdiIcons.trashCanOutline,
                    size: 25,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          subtitle: InkWell(
              overlayColor: MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        alignment: Alignment.bottomCenter,
                        child: ArticleDetailScreen(widget.article, "own")));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Views: " +
                          widget.article['view_count'].toString() +
                          ", Date: " +
                          widget.article['published_on'].toString(),
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6), fontSize: 12.sp)),
                  SizedBox(
                    height: 5.h,
                  ),
                  // Badge(
                  //   offset: Offset(0, 10),
                  //   backgroundColor: bcolor,
                  //   label: Text(" " + widget.article['status'].toString() + " \n"),
                  //   // child: Container(
                  //   //   margin: EdgeInsets.only(bottom: 10),
                  //   // ),
                  // ),
                  FittedBox(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                          color: bcolor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        " " + widget.article['status'].toString() + "",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 12.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              )),
          leading: InkWell(
            overlayColor: MaterialStatePropertyAll(Colors.transparent),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      alignment: Alignment.bottomCenter,
                      child: ArticleDetailScreen(widget.article, "own")));
            },
            child: Container(
                child: CachedNetworkImage(
              imageUrl: ApiConstants.storagePATH +
                  "/image-manager/" +
                  widget.article["image"].toString(),
              imageBuilder: (context, imageProvider) => Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                enabled: true,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: BannerPlaceholder(40, 40),
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.image,
                size: 40,
                color: Colors.white,
              ),
            )),
          ),
        ));
  }
}
