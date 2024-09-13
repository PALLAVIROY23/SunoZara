import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'articles/list.dart';
import 'audio/category_item.dart';
import 'audio/favorite.dart';
import 'dashboard.dart';
import 'product/product_list.dart';
import 'widget/bottom_index.dart';

class DashboardTabScreen extends StatefulWidget {
  int index = 0;
  dynamic cat_id;
  DashboardTabScreen(this.index, {this.cat_id = null, super.key});

  @override
  State<DashboardTabScreen> createState() => _DashboardTabScreenState();
}

class _DashboardTabScreenState extends State<DashboardTabScreen> {
  int selectedIndex = 0;

  bool is_audio_enable = false;
  bool is_book_enable = false;
  bool is_article_enable = false;
  dynamic cat_id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    setState(() {
      selectedIndex = widget.index;
      cat_id = widget.cat_id;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      is_audio_enable = prefs.getBool("is_audio_enable")!;
      is_book_enable = prefs.getBool("is_book_enable")!;
      is_article_enable = prefs.getBool("is_article_enable")!;
    });
  }

  Widget loadScreen(int index, dynamic cat_iid) {
    if (index == 0) {
      return DashboardScreen(
        getIndex: (int index, dynamic cat_iid) {
          // print(cat_iid);
          setState(() {
            selectedIndex = index;
            cat_id = cat_iid;
          });
        },
        getCat: (dynamic cat_iid) {
          setState(() {
            cat_id = cat_iid;
          });
        },
      );
    } else if (index == 1) {
      return CatItemListScreen(
        cat_iid,
        getIndex: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      );
    } else if (index == 2) {
      return ArticleListSCreen(
        getIndex: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      );
    } else if (index == 3) {
      print("Hello");

      if (is_book_enable) {
        return ProductListScreen(
          getIndex: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        );
      } else {
        return MyFavAudioList(
          getIndex: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        );
      }
    } else {
      return MyFavAudioList(
        getIndex: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      );
    }
  }

  Widget loadBottom(int si) {
    return BottomWidgetIndex(
      si,
      getIndex: (int index) {
        setState(() {
          selectedIndex = index;
          cat_id = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: loadBottom(selectedIndex),
        body: loadScreen(selectedIndex, cat_id));
  }
}
