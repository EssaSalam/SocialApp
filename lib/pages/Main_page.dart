import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialchat/widgets/posts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialchat/models/user.dart';
import 'package:socialchat/pages/edit_profile.dart';

import 'package:socialchat/pages/home.dart';
import 'package:socialchat/widgets/header.dart';

import 'package:socialchat/widgets/posts.dart';
import 'package:socialchat/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialchat/widgets/post_tile.dart';
class MainPage extends StatefulWidget {
  final Function logout;
  final String profileId="108822934559647825473";
  const MainPage(this.logout);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final String currentUserId = currentUser?.id;
  String postView = "list";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;
  @override
  void initState() {
    super.initState();
    getProfilePost();

  }
  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  BuildToggleViewPost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.grid_on,
              color: postView == "grid"
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              setBuildTogglePost("grid");
            }),
        IconButton(
            icon: Icon(
              Icons.list,
              color: postView == "list"
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: () {
              setBuildTogglePost("list");
            }),
      ],
    );
  }

  setBuildTogglePost(String view) {
    setState(() {
      postView = view;
    });
  }

  BuildPostProfile() {
    if (isLoading) {
      return circularProgress();
    } else if (postView == "grid") {
      List<GridTile> gridTile = [];
      posts.forEach((post) {
        gridTile.add(GridTile(
          child: PostTile(post: post),
        ));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (postView == "list") {
      return Column(
        children: posts,
      );
    }
  }
  PopupMenuButton _popMenu() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => _getPopupMenu(context),
      onSelected: (String value) {
        print('onSelected');
      },
      onCanceled: () {
        print('onCanceled');
      },
//      child: RaisedButton(onPressed: (){},child: Text('选择'),),
    );
  }

  _getPopupMenu(BuildContext context) {
    return <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        child: TextButton(
          child: Text("LogOut"),
          onPressed: () {
            widget.logout();
            Navigator.of(context).pop();
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts",style: TextStyle(color:Colors.white),),
        centerTitle: true,
        actions: <Widget>[_popMenu()],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          BuildPostProfile(),

        ],
      ));

  }

}
