// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rich_editor/rich_editor.dart';

// class WpadScreen extends StatefulWidget {
//   const WpadScreen({super.key});

//   @override
//   State<WpadScreen> createState() => _WpadScreenState();
// }

// class _WpadScreenState extends State<WpadScreen> {
//   GlobalKey<RichEditorState> keyEditor = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(),
//       body: RichEditor(
//         key: keyEditor,
//         value: '''
//         Hello, This is a rich text Editor for Flutter. It supports most things like Bold, italics and underline.
//         As well as Subscript, Superscript, Colored text, Colors bg text and hyperlink.
//         Images and Videos are also supports
//         ''', // initial HTML data
//         editorOptions: RichEditorOptions(
//           placeholder: 'Start typing',
//           // backgroundColor: Colors.blueGrey, // Editor's bg color
//           // baseTextColor: Colors.white,
//           // editor padding
//           padding: EdgeInsets.symmetric(horizontal: 5.0),
//           // font name
//           baseFontFamily: 'sans-serif',
//           // Position of the editing bar (BarPosition.TOP or BarPosition.BOTTOM)
//           barPosition: BarPosition.TOP,
//         ),

//         // You can return a Link (maybe you need to upload the image to your
//         // storage before displaying in the editor or you can also use base64
//         getImageUrl: (image) {
//           String link = 'https://avatars.githubusercontent.com/u/24323581?v=4';
//           String base64 = base64Encode(image.readAsBytesSync());
//           String base64String = 'data:image/png;base64, $base64';
//           return base64String;
//         },
//         getVideoUrl: (video) {
//           String link = 'https://file-examples-com.github.io/uploads/2017/'
//               '04/file_example_MP4_480_1_5MG.mp4';
//           return link;
//         },
//       ),
//     );
//   }
// }
