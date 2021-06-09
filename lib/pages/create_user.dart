import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socialchat/widgets/header.dart';

class createUser extends StatefulWidget {
  @override
  _createUserState createState() => _createUserState();
}

class _createUserState extends State<createUser> {
  String username = '';
  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //final GlobalKey<ScaffoldMessengerState> _scaffoldKey=
  //GlobalKey<ScaffoldMessengerState>();

  submitData() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text('welcome to chat'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Create User', removeBackButton: true),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'Create User Name',
                        style: TextStyle(fontSize: 25.0),
                      )),
                  new Container(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        children: [
                          new TextFormField(
                            validator: (val) {
                              if (val.trim().length < 3 || val.isEmpty) {
                                return "User Name too short";
                              } else if (val.trim().length > 12) {
                                return "User Name too long";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => username = val,
                            decoration: InputDecoration(
                                labelText: 'UserName',
                                hintText: 'Must be at 3 charter'),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  minWidth: 300.0,
                                  onPressed: () {
                                    submitData();
                                  },
                                  child: new Text(
                                    'submit',
                                    style: TextStyle(color: Colors.white),
                                  )))
                        ],
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
