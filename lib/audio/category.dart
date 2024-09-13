import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../constants.dart';
import '../widget/bottom.dart';

class CategoryListScreenTab extends StatefulWidget {
  const CategoryListScreenTab({super.key});

  @override
  State<CategoryListScreenTab> createState() => _CategoryListScreenTabState();
}

class _CategoryListScreenTabState extends State<CategoryListScreenTab> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
          backgroundColor: THEME_BLACK,
          appBar: AppBar(
            backgroundColor: THEME_BLACK,
            centerTitle: true,
            // leading: Icon(Icons.person_outline),
            automaticallyImplyLeading: true,
            title: Text(
              'DASHBOARD',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            bottom: PreferredSize(
                child: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.3),
                    indicatorColor: Colors.transparent,
                    automaticIndicatorColorAdjustment: false,
                    dividerColor: Colors.transparent,
                    unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400, fontSize: 10),
                    onTap: (value) {
                      //print(value);
                    },
                    tabs: [
                      Tab(
                          child:
                              tabContainer("assets/ab1.png", "15 min shorts")),
                      Tab(
                          child: tabContainer(
                              "assets/ab1.png", "15 min shorts okay for you?")),
                      Tab(
                          child:
                              tabContainer("assets/ab1.png", "15 min shorts")),
                      Tab(
                          child:
                              tabContainer("assets/ab1.png", "15 min shorts")),
                      Tab(
                          child:
                              tabContainer("assets/ab1.png", "15 min shorts")),
                      Tab(
                          child:
                              tabContainer("assets/ab1.png", "15 min shorts")),
                    ]),
                preferredSize: Size.fromHeight(30.0)),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                child: Center(
                  child: Text('Tab 1'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Tab 2'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Tab 3'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Tab 4'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Tab 5'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Tab 6'),
                ),
              ),
            ],
          )),
    );
  }

  Widget tabContainer(String img, String name) {
    return Text(name);
  }

  Widget tabContainer1(String img, String name) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                      image: AssetImage(img), fit: BoxFit.cover)),
            ),
            Expanded(
                child: Text(
              name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ))
          ],
        ));
  }
}
