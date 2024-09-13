import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';

import '../api/api_constant.dart';
import 'details.dart';

class EditReviewArticleScreen extends StatefulWidget {
  dynamic article;
  dynamic myrate;
  Function isReviewed;
  EditReviewArticleScreen(this.article, this.myrate,
      {required this.isReviewed, super.key});

  @override
  State<EditReviewArticleScreen> createState() =>
      _EditReviewArticleScreenState();
}

class _EditReviewArticleScreenState extends State<EditReviewArticleScreen> {
  TextEditingController _review = new TextEditingController();
  bool canComment = true;
  double rateData = 0.0;
  bool submiting = false;
  bool submitted = false;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  loadData() {
    setState(() {
      rateData = double.parse(widget.myrate["rating"].toString());
      _review.text = widget.myrate["comment"];
      canComment = true;
    });
  }

  rateNow() {
    if (_review.text.toString() != "") {
      setState(() {
        submiting = true;
      });
      Fluttertoast.showToast(msg: "Please wait...");
      ApiService()
          .postArticleReview(widget.article["id"].toString(),
              rateData.toString(), _review.text.toString(), '1')
          .then((value) => {rtD(value)});
    } else {
      Fluttertoast.showToast(msg: "Comment can not be blank");
    }
  }

  rtD(data) {
    setState(() {
      submitted = true;
      submiting = false;
      widget.isReviewed(true);
    });
    Fluttertoast.showToast(msg: "Reviews has been updated");
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.leftToRight,
      //         alignment: Alignment.bottomCenter,
      //         child: ArticleDetailScreen(widget.article, "review")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Review: " + widget.article["title"].toString()),
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          bottomNavigationBar: canComment
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: submiting
                      ? Center(
                          child: Container(
                            height: 50.h,
                            width: 50.w,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : (submitted
                          ? SizedBox()
                          : TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.symmetric(vertical: 10.h)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.redAccent)),
                              onPressed: () {
                                rateNow();
                              },
                              child: Text(
                                "Submit Now",
                                style: GoogleFonts.poppins(fontSize: 20.sp),
                              ),
                            )))
              : SizedBox(),
          body: ListView(
            children: [
              SizedBox(
                height: 30.h,
              ),
              if (!submitted) ...{
                Center(
                  child: Container(
                    height: 180.h,
                    width: 180.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                            image: NetworkImage(ApiConstants.storagePATH +
                                "/image-manager/" +
                                widget.article["image"].toString()))),
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    child: RatingBar.builder(
                      initialRating: rateData,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: 35,
                      // ignoreGestures: true,
                      unratedColor: Colors.grey,
                      // itemCount: 5,
                      glow: true,
                      glowColor: Colors.amber,
                      // glow: false,
                      glowRadius: 2,
                      maxRating: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      itemBuilder: (context, _) => Icon(
                        MdiIcons.star,
                        size: 15,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          rateData = rating;
                        });
                        if (rating > 0) {
                          setState(() {
                            canComment = true;
                          });
                        } else {
                          setState(() {
                            canComment = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                canComment
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        child: textFiled(
                            hinttext: "Enter your comment",
                            ttype: TextInputType.text,
                            controller: _review),
                      )
                    : SizedBox()
              } else ...{
                Center(
                  child: Image.asset(
                    "assets/thanks.png",
                    height: 150.h,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: Text(
                    "Thank you for your review.",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp),
                  ),
                )
              }
            ],
          ),
        ));
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      validator,
      bool? readonly}) {
    return Container(
        decoration: BoxDecoration(
            // color: Colors.white, borderRadius: BorderRadius.circular(6)
            ),
        margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 0.w),
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                // height: 50,
                child: TextFormField(
              controller: controller,
              readOnly: readonly ?? false,
              keyboardType: ttype,
              minLines: 4,
              maxLines: 4,
              onTap: onTap,
              validator: validator,
              inputFormatters: inputFormatters,
              style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0)
                  .copyWith(color: Color(0xff020E12)),
              decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: hinttext,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                  // hintText: hinttext,
                  hintStyle: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0)
                      .copyWith(color: Color(0xff020E12).withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.12), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.12), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  )),
            )),
          ],
        ));
  }
}
