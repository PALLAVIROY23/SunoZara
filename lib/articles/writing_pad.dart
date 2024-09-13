import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:page_transition/page_transition.dart';
// import 'package:fresh_quill_extensions/fresh_quill_extensions.dart';
// import 'package:fresh_quill_extensions/presentation/models/config/toolbar/buttons/video.dart';
import 'package:sunozara/api/api.dart';
import 'package:sunozara/api/api_constant.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:sunozara/dashboard_tab.dart';

import '../models/artilce.dart';
import 'list.dart';

class WritingPadScreen extends StatefulWidget {
  ArticleModel article;
  WritingPadScreen(this.article, {super.key});

  @override
  State<WritingPadScreen> createState() => _WritingPadScreenState();
}

class _WritingPadScreenState extends State<WritingPadScreen> {
  QuillController? _controller;
  late QuillEditorController controller;
  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.clean,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];

  final _toolbarColor = Colors.grey.shade200;
  final _backgroundColor = Colors.white70;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle =  TextStyle(
      fontSize: 18.sp,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto');
  final _hintTextStyle =  TextStyle(
      fontSize: 18.sp, color: Colors.black38, fontWeight: FontWeight.normal);

  bool _hasFocus = false;
  bool loading = false;
  bool dloading = false;
  @override
  void initState() {
    controller = QuillEditorController();
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    /// please do not forget to dispose the controller
    controller.dispose();
    super.dispose();
  }

  saveData(String type, BuildContext ctx) {
    if (type == "Draft") {
      setState(() {
        dloading = true;
      });
    } else {
      setState(() {
        loading = true;
      });
    }
    ApiService()
        .updateArticle(widget.article, type)
        .then((value) => {arStatus(value, ctx)});
  }

  arStatus(data, BuildContext ctx) {
    setState(() {
      loading = false;
      dloading = false;
    });
    Fluttertoast.showToast(msg: data["message"].toString());
    Navigator.push(
        ctx,
        PageTransition(
            type: PageTransitionType.leftToRight,
            alignment: Alignment.bottomCenter,
            child: DashboardTabScreen(2)));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white.withOpacity(
              0.6), //This will change the drawer background to blue.
          //other styles
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            decoration:
                BoxDecoration(color: const Color.fromARGB(255, 228, 227, 227)),
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        String? htmlText = await controller.getText();
                        // if (htmlText.length >= 50) {
                        setState(() {
                          widget.article.description = htmlText;
                        });

                        saveData('Draft', context);
                        // } else {
                        //   Fluttertoast.showToast(
                        //       msg: "Article must be of minimum 50 charcaters.");
                        // }
                      },
                      style: ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 20.w))),
                      child: dloading
                          ? Container(
                              height: 30.h,
                              width: 30.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Save Draft",
                              style: GoogleFonts.poppins(
                                  fontSize: 16.sp, fontWeight: FontWeight.w400),
                            )),
                  ElevatedButton(
                      onPressed: () async {
                        String? htmlText = await controller.getText();
                        if (htmlText.length >= 50) {
                          setState(() {
                            widget.article.description = htmlText;
                          });
                          saveData('Pending', context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Article must be of minimum 50 charcaters.");
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.redAccent),
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 20.w))),
                      child: loading
                          ? Container(
                              height: 30.h,
                              width: 30.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Publish",
                              style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ))
                ]),
          ),
          appBar: AppBar(
            title: Text("Description"),
            automaticallyImplyLeading: true,
            actions: [],
          ),
          body: Column(
            children: [
              // QuillToolbar.basic(
              //   controller: _controller!,
              //   axis: Axis.horizontal,
              //   color: Colors.white,
              //   multiRowsDisplay: false,
              //   showInlineCode: true,
              //   showColorButton: true,

              //   embedButtons: FlutterQuillEmbeds.buttons(
              //       showFormulaButton: false,
              //       showCameraButton: true,
              //       showImageButton: true,
              //       showVideoButton: true,
              //       onImagePickCallback: _onImagePickCallback,
              //       // webImagePickImpl: _webImagePickImpl,
              //       onVideoPickCallback: _onVideoPickCallback),
              //   // showBackgroundColorButton: false,
              // ),
              ToolBar(
                toolBarColor: _toolbarColor,
                padding:  EdgeInsets.all(6.w),
                iconSize: 20,
                iconColor: _toolbarIconColor,
                activeIconColor: Colors.redAccent,
                controller: controller,
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                customButtons: [],
              ),
              Expanded(
                child: QuillHtmlEditor(
                  text: widget.article.description.toString(),
                  hintText: 'Start writing here...',
                  controller: controller,
                  isEnabled: true,
                  ensureVisible: false,
                  minHeight: 500.h,
                  autoFocus: false,
                  textStyle: _editorTextStyle,
                  hintTextStyle: _hintTextStyle,
                  hintTextAlign: TextAlign.start,
                  padding:  EdgeInsets.only(left: 10.w, top: 10.h),
                  hintTextPadding:  EdgeInsets.only(left: 20.w),
                  backgroundColor: _backgroundColor,
                  inputAction: InputAction.newline,
                  onEditingComplete: (s) => print('Editing completed $s'),
                  // loadingBuilder: (context) {
                  //   return const Center(
                  //       child: CircularProgressIndicator(
                  //     strokeWidth: 1,
                  //     color: Colors.red,
                  //   ));
                  // },
                  onFocusChanged: (focus) {
                    setState(() {
                      _hasFocus = focus;
                    });
                  },
                  onTextChanged: (text) => print('widget text change $text'),
                  onEditorCreated: () {
                    print('Editor has been loaded');
                    // setHtmlText('Testing text on load');
                  },
                  onEditorResized: (height) => print('Editor resized $height'),
                  onSelectionChanged: (sel) =>
                      print('index ${sel.index}, range ${sel.length}'),
                ),
              ),
            ],
          ),
        ));
  }

  void setHtmlText(String text) async {
    await controller.setText(text);
  }

  Future<String> _upload(File file) async {
    // remove headers if not wanted
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            ApiConstants.baseUrl + ApiConstants.uploadFile)); // your server url
    // any other fields required by your server
    request.files.add(await http.MultipartFile.fromPath(
        'file', '${file.path}')); // file you want to upload

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();

      var arrayObjsText = res;

      var tagObjsJson = jsonDecode(arrayObjsText);
      if (tagObjsJson["success"]) {
        //print(tagObjsJson);
        setState(() {});
      }
      return ApiConstants.storagePATH + "/uploads/" + tagObjsJson["file"];
    } else {
      return "";
    }
  }
}
