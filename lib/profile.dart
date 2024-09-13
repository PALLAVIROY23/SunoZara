import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunozara/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'api/api_constant.dart';
import 'dart:io';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  TextEditingController _name = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _bio = new TextEditingController();
  bool canEdit = false;
  String profilePhoto = "";
  File? _imageFile;
  late BuildContext dialogContext;
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final crp = new ImageCropper();
    crp.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 700,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.redAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Photo',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    ).then((value) => crpD(value));
  }

  crpD(value) {
    setState(() {
      _imageFile = File(value.path);
    });
    _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    // Example URL to upload the image to your server
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.uploadFile + "1");

    // Create multipart request for image upload
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    // Send request
    final response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();

      var arrayObjsText = res;

      var tagObjsJson = jsonDecode(arrayObjsText);
      // Image uploaded successfully
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user_photo", tagObjsJson['file'].toString());

      setState(() {
        profilePhoto = tagObjsJson['file'].toString();
      });
      //print("profilePhoto");
    } else {
      // Error uploading image
      //print('Failed to upload image');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  ajaxLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.redAccent.withOpacity(0.1),
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              height: 100,
              child: Center(
                // padding: EdgeInsets.all(15),
                child: Stack(children: [
                  Positioned(
                      top: 15,
                      right: 18,
                      child: Image.asset(
                        "assets/icon.png",
                        height: 50,
                      )),
                  LoadingAnimationWidget.discreteCircle(
                      color: Colors.redAccent,
                      size: 80,
                      secondRingColor: Colors.white,
                      thirdRingColor: Colors.white)
                ]),
              ),
            ));
      },
    );
  }

  loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name.text = prefs.getString("user_name").toString() != 'null'
          ? prefs.getString("user_name").toString()
          : '';
      _email.text = prefs.getString("user_email").toString() != 'null'
          ? prefs.getString("user_email").toString()
          : '';
      _phone.text = prefs.getString("user_mobile").toString() != 'null'
          ? prefs.getString("user_mobile").toString()
          : '';
      _bio.text = prefs.getString("user_bio").toString() != 'null'
          ? prefs.getString("user_bio").toString()
          : '';
      profilePhoto = prefs.getString("user_photo").toString();
    });
  }

  String? validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  bool validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return false;
    else
      return true;
  }

  updateProfile() {
    bool canContinue = true;
    String msg = "";
    if (_name.text.trim() == "") {
      canContinue = false;
      msg = "Name can not be empty";
    }
    if (!validateMobile(_phone.text)) {
      canContinue = false;
      msg = "Kindly enter valid phone number";
    }

    if (canContinue) {
      ajaxLoader();
      ApiService()
          .updateProfile(
              _name.text, _email.text, _phone.text, _bio.text, profilePhoto)
          .then((value) => pUpd(value));
    } else {
      Fluttertoast.showToast(msg: msg);
    }
  }

  pUpd(value) async {
    Navigator.pop(dialogContext);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("user_name", _name.text);
    prefs.setString("user_email", _email.text);
    prefs.setString("user_mobile", _phone.text);
    prefs.setString("user_bio", _bio.text);
    prefs.setString("user_photo", profilePhoto);
    Fluttertoast.showToast(msg: "Profile details updated");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/player_bg.png"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: canEdit
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
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
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.transparent)),
                            onPressed: () {
                              updateProfile();
                            },
                            child: Text(
                              "Update Profile",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ))
                    ],
                  ),
                )
              : SizedBox(),
          appBar: AppBar(
            title: Text("Edit Profile"),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    canEdit = !canEdit;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(canEdit ? Icons.close : Icons.edit_square),
                ),
              )
            ],
          ),
          body: ListView(
            children: [
              Container(
                  child: Center(
                child: Stack(
                  children: [
                    InkWell(
                        overlayColor:
                            MaterialStatePropertyAll(Colors.transparent),
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white,
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (canEdit) {
                            _pickImage(ImageSource.gallery);
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: ApiConstants.storagePATH +
                              "/author/" +
                              profilePhoto,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 90.0,
                            height: 90.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            MdiIcons.accountCircle,
                            color: Colors.white,
                            size: 90,
                          ),
                        )),
                    canEdit
                        ? Positioned(
                            bottom: 10,
                            right: 6,
                            child:
                                Icon(MdiIcons.cloudUpload, color: Colors.blue))
                        : SizedBox()
                  ],
                ),
              )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  // loginforbetteruserexperienceMM (139:461)
                  'Your Name',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Color(0xffffffff),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              canEdit
                  ? Container(
                      child: textFiled(
                          hinttext: "Enter Name",
                          ttype: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                          controller: _name),
                    )
                  : Container(
                      child: textFiled(
                          hinttext: "Enter Name",
                          ttype: TextInputType.text,
                          readonly: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                          controller: _name),
                    ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  // loginforbetteruserexperienceMM (139:461)
                  'Your Email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Color(0xffffffff),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              canEdit
                  ? Container(
                      child: textFiled(
                          hinttext: "Enter Email",
                          readonly: true,
                          ttype: TextInputType.emailAddress,
                          controller: _email),
                    )
                  : Container(
                      child: textFiled(
                          hinttext: "Enter Email",
                          readonly: true,
                          ttype: TextInputType.emailAddress,
                          controller: _email),
                    ),
              SizedBox(
                height: 15,
              ),
              canEdit || _phone.text.toString() != ""
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        // loginforbetteruserexperienceMM (139:461)
                        'Your Phone',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Color(0xffffffff),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 5,
              ),
              canEdit
                  ? Container(
                      child: textFiled(
                          hinttext: "Enter Phone",
                          ttype: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _phone),
                    )
                  : _phone.text.toString() != ""
                      ? Container(
                          child: textFiled(
                              hinttext: "Enter Phone",
                              readonly: true,
                              ttype: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: _phone),
                        )
                      : SizedBox(),
              SizedBox(
                height: 15,
              ),
              canEdit || _bio.text.toString() != ""
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        // loginforbetteruserexperienceMM (139:461)
                        'Your Bio',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Color(0xffffffff),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 5,
              ),
              canEdit
                  ? Container(
                      child: textFiled1(
                          hinttext: "Enter Bio",
                          ttype: TextInputType.text,
                          controller: _bio),
                    )
                  : _bio.text.toString() != ""
                      ? Container(
                          child: textFiled1(
                              hinttext: "Enter Bio",
                              ttype: TextInputType.text,
                              readonly: true,
                              controller: _bio),
                        )
                      : SizedBox()
            ],
          ),
        ));
  }

  Widget textFiled(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
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
            SizedBox(
                height: 45,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: ttype,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ).copyWith(color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: hinttext,
                      fillColor: readonly != null
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.4),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                      // hintText: hinttext,
                      hintStyle: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0)
                          .copyWith(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      )),
                )),
          ],
        ));
  }

  Widget textFiled1(
      {hinttext,
      TextInputType? ttype,
      TextEditingController? controller,
      VoidCallback? onTap,
      inputFormatters,
      validator,
      bool? readonly}) {
    return Container(
        height: 150,
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
            SizedBox(
                height: 150,
                child: TextFormField(
                  controller: controller,
                  readOnly: readonly ?? false,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 5,
                  onTap: onTap,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ).copyWith(color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      // isDense: true,
                      hintText: hinttext,
                      fillColor: readonly != null
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.4),
                      contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                      prefixIconColor: Color.fromARGB(255, 203, 201, 201),
                      // hintText: hinttext,
                      hintStyle: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0)
                          .copyWith(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(220, 255, 255, 255),
                            width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(220, 255, 255, 255),
                            width: 1),
                        borderRadius: BorderRadius.circular(8),
                      )),
                )),
          ],
        ));
  }
}
