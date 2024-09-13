import 'package:flutter/material.dart';
import 'dart:convert';

import 'select_model.dart';

class SelectCustom extends StatefulWidget {
  final List<SelectModel> sitems;
  final Function(String) onSelectParam;
  String? defaultv;
  SelectCustom(this.sitems, this.defaultv,
      {required this.onSelectParam, Key? key})
      : super(key: key);

  @override
  _SelectCustomState createState() => _SelectCustomState();
}

class _SelectCustomState extends State<SelectCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: EdgeInsets.only(right: 10, left: 10, bottom: 7, top: 7),
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
          height: 10.0,
          alignedDropdown: true,
          child: DropdownButton(
              isExpanded: true,
              dropdownColor: Colors.white,
              value: widget.defaultv,
              items: widget.sitems.map((SelectModel map) {
                return new DropdownMenuItem<String>(
                  value: map.value,
                  child: new Text(map.text,
                      style: new TextStyle(color: Colors.black, fontSize: 13)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.defaultv = value.toString();
                  widget.onSelectParam(value.toString());
                });
              },
              hint: Text("Select item")),
        )));
  }
}
