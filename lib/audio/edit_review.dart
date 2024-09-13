import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/constants.dart';

import '../api/api_constant.dart';
import 'player.dart';

class EditReviewAudioScreen extends StatefulWidget {
  dynamic audio;
  String type;
  dynamic myrate;
  Function isReviewed;
  EditReviewAudioScreen(this.audio, this.type, this.myrate,
      {required this.isReviewed, super.key});

  @override
  State<EditReviewAudioScreen> createState() => _EditReviewAudioScreenState();
}

class _EditReviewAudioScreenState extends State<EditReviewAudioScreen> {
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
          .postAudioReview(widget.audio["id"].toString(), rateData.toString(),
              _review.text.toString(), "1")
          .then((value) => {rtD(value)});
    } else {
      Fluttertoast.showToast(msg: "Comment can not be blank");
    }
  }

  rtD(data) {
    setState(() {
      submitted = true;
      submiting = false;
    });
    setState(() {
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
      //         child: AudioPlayerScreen(
      //           widget.audio,
      //           widget.type,
      //           index: 1,
      //         )));
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
            title: Text("Review: " + widget.audio["title"].toString()),
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          bottomNavigationBar: canComment
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: submiting
                      ? Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : (submitted
                          ? SizedBox()
                          : TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.symmetric(vertical: 10)),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.redAccent)),
                              onPressed: () {
                                rateNow();
                              },
                              child: Text(
                                "Submit Now",
                                style: GoogleFonts.poppins(fontSize: 20),
                              ),
                            )))
              : SizedBox(),
          body: ListView(
            children: [
              SizedBox(
                height: 30,
              ),
              if (!submitted) ...{
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                            image: NetworkImage(ApiConstants.storagePATH +
                                "/audios/" +
                                widget.audio["image"].toString()))),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
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
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                  height: 25,
                ),
                canComment
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
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
                    height: 150,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "Thank you for your review.",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
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
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
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
                      fontSize: 14,
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
