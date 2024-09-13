import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/auth/authentication.dart';

import '../api/storage.dart';
import '../dashboard.dart';
import '../dashboard_tab.dart';

class GoogleSignInButton extends StatefulWidget {
  bool? isChecked;
  GoogleSignInButton(this.isChecked, {super.key});
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;
  bool started_login = false;

  errorUser() {
    setState(() {
      _isSigningIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 430;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _isSigningIn || started_login
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Column(children: [
          ListTile(
            onTap: () async {
              if (widget.isChecked == false) {
                Fluttertoast.showToast(
                    msg:
                    "Kindly accept Terms and conditions to continue");
              } else {
                setState(() {
                  _isSigningIn = true;
                });
                User? user = await Authentication.signInWithGoogle(
                    context: context);
                if (user != null) {
                  setState(() {
                    started_login = true;
                  });

                  ApiService()
                      .providerLogin(

                      user.displayName.toString(),
                      user.email.toString(),
                      user.phoneNumber.toString(),
                      user.photoURL.toString(),
                      user.uid,
                      "google")
                      .then((value) => {loginData(value)});
                } else {
                  errorUser();
                }
              }
            },
            dense: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5))),
            tileColor: Color(0xffe71f2e),
            title: Text(
              "Continue via Google",
              style: GoogleFonts.poppins(
                fontSize: 15 * fem,
                fontWeight: FontWeight.w500,
                height: 1.5 * ffem / fem,
                color: Color(0xffffffff),
              ),
            ),
            minLeadingWidth: 20,
            leading: Icon(
              MdiIcons.google,
              color: Colors.white,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () async {
              if (widget.isChecked == false) {
                Fluttertoast.showToast(
                    msg:
                    "Kindly accept Terms and conditions to continue");
              } else {
                setState(() {
                  _isSigningIn = true;
                });

                User? user = await Authentication.signInWithFacebook(
                    context: context)
                    .then((value) => null)
                    .onError((error, stackTrace) => errorUser());

                if (user != null) {
                  setState(() {
                    started_login = true;
                  });
                  ApiService()
                      .providerLogin(
                      user.displayName.toString(),
                      user.email.toString(),
                      user.phoneNumber.toString(),
                      user.photoURL.toString(),
                      user.uid,
                      "facebook")
                      .then((value) => {loginData(value)});
                } else {
                  errorUser();
                }
              }
            },
            dense: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5))),
            tileColor: Color(0xff1877f2),
            title: Text(
              "Continue via Facebook",
              style: GoogleFonts.poppins(
                fontSize: 15 * fem,
                fontWeight: FontWeight.w500,
                height: 1.5 * ffem / fem,
                color: Color(0xffffffff),
              ),
            ),
            minLeadingWidth: 20,
            leading: Icon(
              Icons.facebook,
              color: Colors.white,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ),
        ]));
  }

  loginData(user) {
    //print(user);
    setState(() {
      _isSigningIn = false;
    });
    DataStorage.setData("user_token", user['token'].toString());
    DataStorage.setData("user_name", user["user"]['name'].toString());
    DataStorage.setData("user_email", user["user"]['email'].toString());
    DataStorage.setData("user_mobile", user["user"]['mobile'].toString());
    DataStorage.setData("user_bio", user["user"]['description'].toString());
    DataStorage.setData("user_photo", user["user"]['profile_photo'].toString());
    DataStorage.setData("user_id", user["user"]['id'].toString());
    DataStorage.setData("user_slug", user["user"]['slug'].toString());

    // //print(user);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: DashboardTabScreen(0)));
  }
}
