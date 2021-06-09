import 'package:flutter/material.dart';
AppBar header(context,{bool isAppTitle=false,String titleText,removeBackButton=false}){
  return AppBar(
    automaticallyImplyLeading: removeBackButton?false:true,
    title: Text(isAppTitle?'Social Chat':titleText,
      style: TextStyle(fontSize: isAppTitle?30.0:20.0,
          color:Colors.white,
          fontFamily:isAppTitle?'Signatra':'' ),),
    backgroundColor: Theme.of(context).primaryColor,
    centerTitle: true,
  );
}