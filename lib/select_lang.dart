import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'dashboard_tab.dart';

class SelectLangScreen extends StatefulWidget {
  Function updateLang;
  SelectLangScreen({required this.updateLang, super.key});

  @override
  State<SelectLangScreen> createState() => _SelectLangScreenState();
}

class _SelectLangScreenState extends State<SelectLangScreen> {
  dynamic languages = [];
  List<dynamic> selectedLang = [];
  List<HexColor> colors = [
    HexColor("cb5040"),
    HexColor("ecd33b"),
    HexColor("1eafde"),
    HexColor("f1959f"),
    HexColor("ff9800"),
    HexColor("6cd2a9"),
    HexColor("ab466d"),
    HexColor("96ae84"),
    HexColor("ff5722"),
    HexColor("9c27b0"),
  ];
  selectLang(String id) async {
    List<dynamic> sl = selectedLang;
    if (sl.contains(id)) {
      sl.remove(id.toString());
    } else {
      sl.add(id.toString());
    }

    setState(() {
      selectedLang = sl;
    });
  }

  loadLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic sliderList = jsonDecode(prefs.getString("languages").toString());

    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());
      setState(() {
        selectedLang = sllangs;
      });
    }

    if (sliderList != 'null') {
      setState(() {
        languages = sliderList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLang();
  }

  submit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("selected_langs", jsonEncode(selectedLang));
    setState(() {
      widget.updateLang(true);
    });
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.leftToRight,
    //         alignment: Alignment.bottomCenter,
    //         child: DashboardTabScreen(0)));
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
            height: 300,
            child: Scaffold(
              backgroundColor: HexColor("16181f"),
              body: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25, top: 25, bottom: 10),
                    child: Text(
                      "Explore content by language",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: Wrap(
                      spacing: 10.0,
                      children:
                          List<Widget>.generate(languages.length, (int i) {
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            languages[i]['name'].toString(),
                            style: GoogleFonts.roboto(
                                color: colors[i],
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          labelStyle: TextStyle(
                            color: selectedLang
                                    .contains(languages[i]['id'].toString())
                                ? Colors.white
                                : Colors.black,
                          ),
                          selected: selectedLang
                              .contains(languages[i]['id'].toString()),
                          selectedColor: Colors.transparent,
                          onSelected: (bool selected) {
                            selectLang(languages[i]['id'].toString());
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                                color: selectedLang
                                        .contains(languages[i]['id'].toString())
                                    ? colors[i]
                                    : Colors.grey.withOpacity(0.4),
                                width: selectedLang
                                        .contains(languages[i]['id'].toString())
                                    ? 2
                                    : 2),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
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
                                fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            submit();
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
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
