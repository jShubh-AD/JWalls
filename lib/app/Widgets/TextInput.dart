import 'dart:async';

import 'package:flutter/material.dart';


class InputText extends StatelessWidget {
  InputText({super.key, required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final void Function(String) onSubmitted;
final FocusNode searchFocusNode = FocusNode();
  bool isDarkMode(BuildContext context){
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = isDarkMode(context);
    return TextField(
      focusNode: searchFocusNode,
      //autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      style: TextStyle(
        color: Colors.black
      ),
      cursorColor: Colors.black,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: InkWell(onTap: (){
          controller.clear();
          searchFocusNode.requestFocus();
          },child: Icon(Icons.close, color: Colors.grey.shade600)),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(30)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkMode? Colors.white : Colors.black),
            borderRadius: BorderRadius.circular(30)
        ),
        errorBorder: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600 ,),
          hint: Text('Search',style: TextStyle(color: Colors.grey.shade600,fontSize: 18),)
      ),
    );
  }
}
