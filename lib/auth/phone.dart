import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/dashboard.dart';

import '../constants.dart';
import '../dashboard_tab.dart';
import 'login.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  TextEditingController _phone = new TextEditingController();
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
              // group1tqP (139:449)
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // sunozaralogo1S6D (139:452)
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 13 * fem, 14 * fem),
                    width: 188 * fem,
                    height: 72 * fem,
                    child: Image.asset(
                      'assets/page-1/images/sahitya-kriti-logo-1.png',
                    ),
                  ),
                  Container(
                      // readlistenthousandsofstoriesfo (139:450)
                      margin: EdgeInsets.fromLTRB(
                          1 * fem, 0 * fem, 0 * fem, 40 * fem),
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
                          'Enter Phone Number',
                          style: GoogleFonts.poppins(
                            fontSize: 18 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.5 * ffem / fem,
                            color: Color(0xffffffff),
                          ),
                        ),
                        SizedBox(
                          height: 20 * fem,
                        ),
                        Container(
                          child: textFiled(
                              hinttext: "Enter Phone Number",
                              ttype: TextInputType.phone,
                              prefixIcon: Container(
                                padding: EdgeInsets.only(left: 5, top: 10),
                                child: Text(
                                  "+91",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color:
                                          const Color.fromARGB(255, 94, 93, 93),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              controller: _phone),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10 * fem,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: DashboardTabScreen(0)));
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
                        "Continue",
                        style: GoogleFonts.poppins(
                          fontSize: 18 * fem,
                          fontWeight: FontWeight.w500,
                          height: 1.5 * ffem / fem,
                          color: Color(0xffffffff),
                        ),
                      ),
                      minLeadingWidth: 20,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50 * fem,
                  ),
                  Container(
                    // newuserregisternowJNd (139:462)
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 0 * fem),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                alignment: Alignment.bottomCenter,
                                child: LoginScreen()));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.w500,
                            height: 1.5 * ffem / fem,
                            color: Color(0xffffffff),
                          ),
                          children: [
                            TextSpan(
                              text: 'New User? ',
                            ),
                            TextSpan(
                              text: 'Register Now',
                              style: GoogleFonts.poppins(
                                fontSize: 16 * ffem,
                                fontWeight: FontWeight.w500,
                                height: 1.5 * ffem / fem,
                                color: Color(0xffe71f2e),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      required Widget prefixIcon,
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
            // Padding(
            //   padding: EdgeInsets.only(left: 3),
            //   child: Text(
            //     hinttext,
            //     style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            //   ),
            // ),
            // SizedBox(
            //   height: 4,
            // ),
            SizedBox(
                height: 50,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: ttype,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4)
                      .copyWith(color: Color(0xff020E12)),
                  decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: hinttext,
                      fillColor: const Color.fromARGB(220, 255, 255, 255),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      prefixIcon: prefixIcon,
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
