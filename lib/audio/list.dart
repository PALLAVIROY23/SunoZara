import 'package:flutter/material.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/widget/audio_card_horizontal.dart';

import '../widget/audio_card.dart';
import '../widget/bottom.dart';

class AudioCatList extends StatefulWidget {
  const AudioCatList({super.key});

  @override
  State<AudioCatList> createState() => _AudioCatListState();
}

class _AudioCatListState extends State<AudioCatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: THEME_BLACK,
        title: Text("Audiobooks"),
        automaticallyImplyLeading: true,
      ),
      bottomNavigationBar: BottomWidget(0),
      body: ListView(children: [
        SizedBox(
          height: 10,
        ),
        for (int i = 0; i < 15; i++) ...{AudioCardHorizontalWidget("s", 's')}
      ]),
    );
  }
}
