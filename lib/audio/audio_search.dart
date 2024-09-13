import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';

import '../search.dart';
import '../widget/audio_card.dart';
import '../widget/bottom.dart';
import '../widget/drawer.dart';

class AudioSearchListScreen extends StatefulWidget {
  const AudioSearchListScreen({super.key});

  @override
  State<AudioSearchListScreen> createState() => _AudioSearchListScreenState();
}

class _AudioSearchListScreenState extends State<AudioSearchListScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      endDrawer: DrawerWidget(),
      appBar: AppBar(
          actions: [
            Container(
              margin: EdgeInsets.only(right: 5),
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  size: 40,
                ),
                onPressed: () => _key.currentState!.openEndDrawer(),
              ),
            )
          ],
          backgroundColor: THEME_BLACK,
          automaticallyImplyLeading: false,
          title: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  // color: const Color.fromARGB(45, 255, 255, 255),
                  borderRadius: BorderRadius.circular(60)),
              child: TextFormField(
                onTap: () {
                  //print("Hello");
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          alignment: Alignment.bottomCenter,
                          child: SearchScreen()));
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    hintText: "Search your favorite Audiobooks",
                    fillColor: Color(0xFF161616),
                    contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.4399999976158142),
                    ),
                    suffixIcon: Icon(
                      MdiIcons.microphone,
                      color: Colors.white.withOpacity(0.4399999976158142),
                    ),
                    prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                    // hintText: hinttext,
                    hintStyle: GoogleFonts.roboto(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0)
                        .copyWith(
                            color:
                                Colors.white.withOpacity(0.4399999976158142)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.12), width: 1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.12), width: 1),
                      borderRadius: BorderRadius.circular(60),
                    )),
              ),
            ),
          )),
      bottomNavigationBar: BottomWidget(1),
      body: ListView(children: [
        SizedBox(
          height: 10,
        ),
        for (int i = 0; i < 15; i++) ...{
          AudioCardHorizontalWidget("", "search")
        }
      ]),
    );
  }
}
