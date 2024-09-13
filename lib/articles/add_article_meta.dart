import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/articles/wpad.dart';
import 'package:sunozara/articles/writing_pad.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/models/artilce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_constant.dart';
import '../placeholders.dart';
import '../widget/select.dart';
import '../widget/select_model.dart';

class AddArticleMetaSCreen extends StatefulWidget {
  ArticleModel article;
  AddArticleMetaSCreen(this.article, {super.key});

  @override
  State<AddArticleMetaSCreen> createState() => _AddArticleMetaSCreenState();
}

class _AddArticleMetaSCreenState extends State<AddArticleMetaSCreen> {
  TextEditingController _title = new TextEditingController();
  List<SelectModel> languages = [];
  List<SelectModel> cats = [];

  String? selectedLanguage;
  String? selectedCat;
  dynamic catList = [];
  bool catLoaded = false;
  List<SelectModel> images = [];
  List<int> selectedTags = [];
  List<ValueItem> tags = [];
  List<SelectModel> utags = [];
  List<String> mytags = [];
  bool canApplyTag = false;
  String selected_image = "";
  String selected_image_src = "";
  List<ValueItem> soptions = [];
  // ArticleModel article = ArticleModel(
  //     title: "",
  //     language: "",
  //     category: "",
  //     thumb_id: "",
  //     description: "",
  //     article_id: "");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    ApiService().getArticleCatData().then((value) => {catData(value)});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic langs = jsonDecode(prefs.getString("languages").toString());
    List<SelectModel> xlngs = [];
    for (int i = 0; i < langs.length; i++) {
      xlngs.add(
          SelectModel(langs[i]["id"].toString(), langs[i]["name"].toString()));
    }
    setState(() {
      languages = xlngs;
    });
    // //print(widget.article.tags);
    setState(() {
      _title.text = widget.article.title.toString();
      selectedLanguage = widget.article.language;
      selectedCat = widget.article.category;
      selected_image = widget.article.thumb_id.toString();
      selected_image_src = widget.article.thumb.toString();
      // mytags = widget.article.tags;
    });
  }

  catData(data) {
    List<SelectModel> xlngs = [];
    for (int i = 0; i < data["data"].length; i++) {
      xlngs.add(SelectModel(data["data"][i]["id"].toString(),
          data["data"][i]["name"].toString()));
    }

    setState(() {
      catList = data["data"];
      cats = xlngs;
      catLoaded = true;
    });
    if (widget.article.category != null) {
      List<ValueItem> xtags = [];
      List<ValueItem> xstags = [];
      List<SelectModel> imgx = [];
      for (int i = 0; i < catList.length; i++) {
        if (catList[i]["id"].toString() == widget.article.category) {
          for (int j = 0; j < catList[i]["tags"].length; j++) {
            //print(catList[i]["tags"][j]["id"].toString());
            if (mytags.contains(catList[i]["tags"][j]["id"].toString())) {
              xstags.add(ValueItem(
                  value: catList[i]["tags"][j]["id"].toString(),
                  label: catList[i]["tags"][j]["name"].toString()));
            }
            xtags.add(ValueItem(
                value: catList[i]["tags"][j]["id"].toString(),
                label: catList[i]["tags"][j]["name"].toString()));
          }
          for (int j = 0; j < catList[i]["images"].length; j++) {
            imgx.add(SelectModel(catList[i]["images"][j]["id"].toString(),
                catList[i]["images"][j]["image"].toString()));
          }
          break;
        }
      }

      setState(() {
        // tags = xtags;

        canApplyTag = true;
        images = imgx;
        soptions = xstags;
      });
      //print(soptions);
    }
  }

  saveData() {
    bool canContinue = true;
    String msg = "";
    if (selected_image == "") {
      canContinue = false;
      msg = "Kindly select thumbnail";
    }
    if (selectedCat == null) {
      canContinue = false;
      msg = "Kindly select Category";
    }

    if (selectedLanguage == null) {
      canContinue = false;
      msg = "Kindly select language";
    }
    if (_title.text == "") {
      canContinue = false;
      msg = "Kindly provide title";
    }
    if (!canContinue) {
      Fluttertoast.showToast(msg: msg);
    } else {
      setState(() {
        widget.article.title = _title.text.toString();
        widget.article.language = selectedLanguage.toString();
        widget.article.category = selectedCat.toString();
        widget.article.thumb_id = selected_image;
      });
      // Navigator.push(
      //     context,  PageTransition(type: PageTransitionType.leftToRight,alignment: Alignment.bottomCenter, child: WpadScreen()));
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight,
              alignment: Alignment.bottomCenter,
              child: WritingPadScreen(widget.article)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.redAccent.shade400,
                    Colors.blue,
                  ],
                ),
                borderRadius: BorderRadius.circular(25)),
            child: TextButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 10)),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.transparent)),
              onPressed: () {
                saveData();
              },
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text("Start writing"),
          ),
          body: ListView(children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: textFiled(
                  hinttext: "Title*",
                  lines: 3,
                  ttype: TextInputType.text,
                  controller: _title),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                "Select Language",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: SelectCustom(
                languages,
                selectedLanguage,
                onSelectParam: (v) {
                  setState(() {
                    selectedLanguage = v;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                "Select Category",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: SelectCustom(
                cats,
                selectedCat,
                onSelectParam: (v) {
                  List<ValueItem> xtags = [];
                  List<SelectModel> imgx = [];
                  for (int i = 0; i < catList.length; i++) {
                    if (catList[i]["id"].toString() == v) {
                      for (int j = 0; j < catList[i]["tags"].length; j++) {
                        xtags.add(ValueItem(
                            value: catList[i]["tags"][j]["id"].toString(),
                            label: catList[i]["tags"][j]["name"].toString()));
                      }
                      for (int j = 0; j < catList[i]["images"].length; j++) {
                        imgx.add(SelectModel(
                            catList[i]["images"][j]["id"].toString(),
                            catList[i]["images"][j]["image"].toString()));
                      }
                      break;
                    }
                  }

                  setState(() {
                    // tags = xtags;
                    selectedCat = v;
                    canApplyTag = true;
                    images = imgx;
                    selected_image = "";
                    selected_image_src = "";
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            canApplyTag
                ? tags.length > 0
                    ? Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 5),
                        child: Text(
                          "Select Tags",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      )
                    : SizedBox()
                : SizedBox(),
            canApplyTag
                ? tags.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: MultiSelectDropDown(
                          onOptionSelected: (List<ValueItem> selectedOptions) {
                            List<String> tgx = [];
                            for (int i = 0; i < selectedOptions.length; i++) {
                              tgx.add(selectedOptions[i].value.toString());
                            }
                            setState(() {
                              // widget.article.tags = tgx;
                            });
                          },
                          selectedOptions: soptions,
                          options: tags,
                          hint: "Select Tags",
                          padding: EdgeInsets.symmetric(vertical: 0),
                          hintStyle: GoogleFonts.poppins(),
                          selectionType: SelectionType.multi,
                          chipConfig: const ChipConfig(
                              backgroundColor: Colors.redAccent,
                              wrapType: WrapType.wrap,
                              spacing: 2,
                              runSpacing: 2),
                          dropdownHeight: 300,
                          optionTextStyle: const TextStyle(fontSize: 14),
                          selectedOptionIcon: const Icon(Icons.check_circle),
                          selectedOptionTextColor: Colors.redAccent,
                        ),
                      )
                    : SizedBox()
                : SizedBox(),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Container(
                            decoration: BoxDecoration(color: THEME_BLACK),
                            margin: EdgeInsets.only(top: 30),
                            child: Scaffold(
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                title: Text("Select Thumbnail"),
                                backgroundColor: THEME_BLACK,
                                foregroundColor: Colors.white,
                              ),
                              body: images.length == 0
                                  ? Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Center(
                                        child: Text(
                                          "Thumbnails not found",
                                          style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                    )
                                  : GridView.count(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      children: [
                                        for (int i = 0;
                                            i < images.length;
                                            i++) ...{
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                selected_image =
                                                    images[i].value.toString();
                                                selected_image_src =
                                                    images[i].text.toString();
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  ApiConstants.storagePATH +
                                                      "/image-manager/" +
                                                      images[i].text.toString(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 200,
                                                height: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          Colors.grey.shade100,
                                                      enabled: true,
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        child:
                                                            BannerPlaceholder(
                                                                130, 200),
                                                      )),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.image),
                                            ),
                                          )
                                        }
                                      ],
                                    ),
                            ));
                      });
                },
                dense: true,
                title: Text(
                  "Select Thumbnail",
                  style: GoogleFonts.poppins(),
                ),
                trailing: Icon(MdiIcons.chevronRight),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            selected_image_src != ""
                ? Image.network(
                    ApiConstants.storagePATH +
                        "/image-manager/" +
                        selected_image_src,
                    height: 200,
                    width: 200,
                  )
                : SizedBox(),
            SizedBox(
              height: 50,
            )
          ]),
        ));
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      required int lines,
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
            Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(
                hinttext,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            SizedBox(
                // height: 50,
                child: TextFormField(
              controller: controller,
              readOnly: readonly ?? false,
              keyboardType: ttype,
              onTap: onTap,
              minLines: lines,
              maxLines: lines,
              validator: validator,
              inputFormatters: inputFormatters,
              style: GoogleFonts.roboto(
                fontSize: 16,
              ).copyWith(color: Color(0xff020E12)),
              decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: hinttext,
                  fillColor: const Color.fromARGB(220, 255, 255, 255),
                  contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
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
