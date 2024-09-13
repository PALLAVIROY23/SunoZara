import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/auth/login.dart';
import 'package:sunozara/constants.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/storage.dart';
import 'dashboard.dart';
import 'dashboard_tab.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    waitTime();
    super.initState();
  }

  waitTime() async {
    ApiService()
        .appConfig()
        .then((value) => {appData(value)})
        .onError((error, stackTrace) => {checkLogin()});
  }

  appData(appData) async {
    print(appData);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_audio_enable", appData['is_audio_enable']);
    await prefs.setBool("is_book_enable", appData['is_book_enable']);
    await prefs.setBool("is_article_enable", appData['is_article_enable']);
    await prefs.setString("app_version", appData['app_version'].toString());
    await prefs.setString("RZP_KEY", appData['RZP_KEY'].toString());
    await prefs.setString(
        "languages", jsonEncode(appData['languages']).toString());
    await prefs.setString("tc", appData['tc'].toString());
    await prefs.setBool("subscription", false);
    // await Future.delayed(const Duration(seconds: 5));
    checkLogin();
  }

  checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = prefs.getString("user_token").toString();
    //print(user_token);
    if (user_token != 'null') {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(0)));
    } else {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.bottomCenter,
              child: LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 430;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/bg.png",
                ),
                fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: THEME_BLACK.withOpacity(0.7),
            body: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.4),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        // sunozaralogo1kmw (138:9)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 15 * fem, 14 * fem),
                        width: 188 * fem,
                        height: 72 * fem,
                        child: Image.asset(
                          'assets/icon.png',
                          height: 50,
                        ),
                      ),
                      Container(
                        // writereadlistenthousandsofstor (138:8)
                        constraints: BoxConstraints(
                          maxWidth: 310 * fem,
                        ),
                        child: GlowText(
                          'Write, Read & Listen thousands of stories for free in your mother language',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 15 * ffem,
                              fontWeight: FontWeight.w500,
                              height: 1.5 * ffem / fem,
                              color: TEXT_WHITE_SHADE),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     waitTime();
                      //   },
                      //   child: Text("Continue"),
                      // )
                    ],
                  ),
                ))));
  }
}
