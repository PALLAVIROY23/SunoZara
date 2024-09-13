import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterArticleScreen extends StatefulWidget {
  String selected;
  Function getSort;
  FilterArticleScreen(this.selected, {required this.getSort, super.key});

  @override
  State<FilterArticleScreen> createState() => _FilterArticleScreenState();
}

class _FilterArticleScreenState extends State<FilterArticleScreen> {
  List<HexColor> colors = [
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
    HexColor("ffffff"),
  ];
  List<String> names = ["Most popular", "Recent articles", "Old articles"];
  List<String> filter_by = ["by_popular", "by_date_desc", "by_date_asc"];
  String selected = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() {
    setState(() {
      selected = widget.selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // canPop: true,

        onWillPop: () {
          // Navigator.pushReplacement(
          //     context,
          //     PageTransition(
          //         type: PageTransitionType.leftToRight,
          //         alignment: Alignment.bottomCenter,
          //         child: DashboardScreen()));
          return Future<bool>.value(true);
        },
        child: Container(
            height: 300.h,
            child: Scaffold(
              backgroundColor: HexColor("16181f"),
              body: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25, top: 25, bottom: 10),
                    child: Text(
                      "Filter article by",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
                    child: Wrap(
                      spacing: 10.0,
                      children: List<Widget>.generate(names.length, (int i) {
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            names[i].toString(),
                            style: GoogleFonts.roboto(
                                color: colors[i],
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp),
                          ),
                          labelStyle: TextStyle(
                            color: selected == filter_by[i]
                                ? Colors.white
                                : Colors.black,
                          ),
                          selected: selected == filter_by[i],
                          selectedColor: Colors.transparent,
                          onSelected: (bool s) {
                            setState(() {
                              selected = filter_by[i];
                            });
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                                color: selected == filter_by[i]
                                    ? colors[i]
                                    : Colors.grey.withOpacity(0.4),
                                width: selected == filter_by[i] ? 2 : 2),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0.w, vertical: 5.0.h),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              widget.getSort(selected);
                            });
                            Navigator.pop(context);
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              widget.getSort(selected);
                            });
                            Navigator.pop(context);
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 10.h),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Apply filter",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
