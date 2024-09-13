import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/auth/authentication.dart';
import 'package:sunozara/auth/google.dart';
import 'package:sunozara/auth/phone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sunozara/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';
import '../brwoser.dart';
import '../constants.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../dashboard_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool? isChecked = false;
  String html = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    waitTime();
    checkLogin();
  }

  waitTime() async {
    // await Future.delayed(const Duration(seconds: 5));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      html = prefs.getString("tc").toString();
    });
    ApiService()
        .appConfig()
        .then((value) => {appData(value)})
        .onError((error, stackTrace) => {waitTime()});
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
    setState(() {
      html = appData['tc'].toString();
    });
  }

  checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = prefs.getString("user_token").toString();
    if (user_token != 'null') {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              alignment: Alignment.bottomCenter,
              child: DashboardTabScreen(0)));
    }
  }

  openTc() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SafeArea(
            child: Container(
          // height: 120,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            title: Column(
              children: [
                Text(
                  'Terms & Conditions',
                  style: GoogleFonts.roboto(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
            content: Container(
              // height: 120,
              child: SingleChildScrollView(
                child: HtmlWidget(
                  html,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(
                  'Go back',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(
                  'I accept',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    isChecked = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ));
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to Exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  SystemNavigator.pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
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
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                backgroundColor: THEME_BLACK.withOpacity(1),
                body: Container(
                  // group1tqP (139:449)
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // sunozaralogo1S6D (139:452)

                        width: MediaQuery.sizeOf(context).width,
                        height: 200,
                        child: Image.asset(
                          'assets/logo.png',
                        ),
                      ),
                      Container(
                          // readlistenthousandsofstoriesfo (139:450)
                          margin: EdgeInsets.fromLTRB(
                              20 * fem, 0 * fem, 20 * fem, 60 * fem),
                          constraints: BoxConstraints(
                            maxWidth: 287 * fem,
                          ),
                          child: GlowText(
                            'Read & Listen thousands of stories for free in your mother language',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                color: TEXT_WHITE_SHADE),
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.055,
                      ),
                      Container(
                        // group5cuo (139:453)
                        margin: EdgeInsets.fromLTRB(
                            27 * fem, 0 * fem, 26 * fem, 0 * fem),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              // loginforbetteruserexperienceMM (139:461)
                              'Login for better user Experience',
                              style: GoogleFonts.poppins(
                                fontSize: 18 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                color: Color(0xffffffff),
                              ),
                            ),
                            SizedBox(
                              height: 40 * fem,
                            ),
                            FutureBuilder(
                              future: Authentication.initializeFirebase(
                                  context: context),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  // return Text("Error: ${snapshot.error}",
                                  //     style: GoogleFonts.roboto(
                                  //         color: Colors.white));
                                  return GoogleSignInButton(isChecked);
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return GoogleSignInButton(isChecked);
                                }
                                return GoogleSignInButton(isChecked);
                              },
                            ),

                            // Container(
                            //   // newuserregisternowJNd (139:462)
                            //   margin: EdgeInsets.fromLTRB(
                            //       0 * fem, 0 * fem, 1 * fem, 0 * fem),
                            //   child: TextButton(
                            //     onPressed: () {
                            //       Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) => DashboardScreen()));
                            //     },
                            //     style: TextButton.styleFrom(
                            //       padding: EdgeInsets.zero,
                            //     ),
                            //     child: RichText(
                            //       text: TextSpan(
                            //         style: GoogleFonts.poppins(
                            //           fontSize: 16 * ffem,
                            //           fontWeight: FontWeight.w500,
                            //           height: 1.5 * ffem / fem,
                            //           color: Color(0xffffffff),
                            //         ),
                            //         children: [
                            //           TextSpan(
                            //             text: 'New User? ',
                            //           ),
                            //           TextSpan(
                            //             text: 'Register Now',
                            //             style: GoogleFonts.poppins(
                            //               fontSize: 16 * ffem,
                            //               fontWeight: FontWeight.w500,
                            //               height: 1.5 * ffem / fem,
                            //               color: Color(0xffe71f2e),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Checkbox(
                              tristate: false,
                              value: isChecked,
                              checkColor: Colors.redAccent,
                              fillColor: MaterialStatePropertyAll(Colors.white),
                              onChanged: (bool? value) {
                                if (value == true) {
                                  openTc();
                                }

                                // setState(() {
                                //   isChecked = value;
                                // });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                // bycontinueyouwillacceptourtcan (139:451)
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 16 * ffem,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5 * ffem / fem,
                                    color: Color(0xffffffff),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'By continue you will accept our ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'T&C',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xffe71f2e),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRight,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: MyBrowser(
                                                      "https://sunozara.com/page/terms-and-conditions")));
                                        },
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy policy',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5 * ffem / fem,
                                        color: Color(0xffe71f2e),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRight,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: MyBrowser(
                                                      "https://sunozara.com/page/privacy-and-policy")));
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ))));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    //print(googleUser);
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();
    //print(loginResult);
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
}
