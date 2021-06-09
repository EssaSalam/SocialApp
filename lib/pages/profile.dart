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

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postView = "grid";
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
    getFollowers();
    getFollowing();
    checkIsFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot=await followersRef
        .document(widget.profileId)
        .collection("userfollowers")
        .getDocuments();
    setState(() {
      followersCount=snapshot.documents.length;
    });
  }

  getFollowing() async{
    QuerySnapshot snapshot=await followingRef
        .document(widget.profileId)
        .collection("userfollowering")
        .getDocuments();
    setState(() {
      followingCount=snapshot.documents.length;
    });
  }

  checkIsFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection("userfollowers")
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  BuildCount(String name, String count) {
    return Column(
      children: <Widget>[
        new Text(
          count,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        new Text(
          name,
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      ],
    );
  }

  editProfileButton() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditProfile(currentUserId: currentUserId);
    }));
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .document(widget.profileId)
        .collection('userfollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      doc.reference.delete();
    });

    followingRef
        .document(currentUserId)
        .collection('userfollowering')
        .document(widget.profileId)
        .get()
        .then((doc) {
      doc.reference.delete();
    });

    feedsRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .get()
        .then((doc) {
      doc.reference.delete();
    });
  }

  handlefollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userfollowers')
        .document(currentUserId)
        .setData({});

    followingRef
        .document(currentUserId)
        .collection('userfollowering')
        .document(widget.profileId)
        .setData({});

    feedsRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  BuildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return BuildButton(text: "Edit Profile", function: editProfileButton);
    } else if (isFollowing) {
      return BuildButton(text: "UnFollow", function: handleUnfollowUser);
    } else if (!isFollowing) {
      return BuildButton(text: "Follow", function: handlefollowUser);
    }
  }

  BuildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: FlatButton(
          onPressed: function,
          child: Container(
            width: 250.0,
            height: 30.0,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20.0)),
          )),
    );
  }

  BuildProfileHeader() {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                      radius: 40.0,
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                BuildCount("Posts", postCount.toString()),
                                BuildCount("Followers", followersCount.toString()),
                                BuildCount("Following", followingCount.toString()),
                              ],
                            ),
                            BuildProfileButton(),
                          ],
                        ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user.displayName,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user.username,
                    style: TextStyle(color: Colors.grey, fontSize: 18.0),
                  ),
                )
              ],
            ),
          );
        });
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

  @override
  Widget build(BuildContext context) {
    print(widget.profileId+"jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
    return Scaffold(
        appBar: header(context, titleText: "Profile"),
        body: ListView(
          children: <Widget>[
            BuildProfileHeader(),
            Divider(
              height: 2.0,
            ),
            BuildToggleViewPost(),
            Divider(
              height: 2.0,
            ),
            BuildPostProfile(),
          ],
        ));
  }
}
