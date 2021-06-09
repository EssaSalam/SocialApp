import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialchat/models/user.dart';
import 'package:socialchat/pages/activity_feed.dart';
import 'package:socialchat/pages/create_user.dart';
import 'package:socialchat/pages/home.dart';
import 'package:socialchat/pages/upload.dart';
import 'package:socialchat/pages/search.dart';
import 'package:socialchat/pages/timeline.dart';
import 'package:socialchat/pages/profile.dart';

import 'Main_page.dart';

final googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection("users");
final postsRef = Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection("comments");
final feedsRef = Firestore.instance.collection("feed");
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");

final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageControler = new PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("error iss $err");
    });

    try {
      googleSignIn.signInSilently(suppressErrors: false).then((account) {
        handleSignIn(account);
      }).catchError((err) {
        print("error in reopen $err");
      });
    } catch (e) {
      print("signInSilently error $e");
    }
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //===========get current user
    final GoogleSignInAccount user = googleSignIn.currentUser;

    //===========check user exists in table users by id
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    String username = "";
    if (!doc.exists) {
      //==========if not exsit create page for add usename
      username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => createUser()));
      //==========insert data in table users
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.displayName);
  }

  @override
  void dispose() {
    super.dispose();
    pageControler.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  void logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageControler.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }


  Widget BuildAuthScreen() {
    //home page at authentication

    return Scaffold(

      body: PageView(
        children: <Widget>[
          MainPage(logout),
          //Timeline(),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(
            profileId: currentUser?.id,
          ),
        ],
        controller: pageControler,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          activeColor: Theme.of(context).primaryColor,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none)),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt)),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.person)),
          ]),
    );
  }

  Widget BuildUnAuthScreen() {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 70.0, left: 20.0, bottom: 30.0),
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                  Text("Welcome to Social Chat"),
                ],
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0))),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        login();
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: 10.0),
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                          child: Text("Sign in By google",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white))),
                    )
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? BuildAuthScreen() : BuildUnAuthScreen();
  }
}
