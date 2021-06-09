import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialchat/models/user.dart';
import 'package:socialchat/pages/comments.dart';
import 'package:socialchat/pages/home.dart';
import 'package:socialchat/widgets/progress.dart';

class Post extends StatefulWidget {
  List list = [5, 2, 8];
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      ownerId: doc["ownerId"],
      username: doc["username"],
      location: doc["location"],
      description: doc["description"],
      mediaUrl: doc["mediaUrl"],
      likes: doc["likes"],
    );
  }

  int getlikeCounts(Map likes) {
    if (likes == null) return 0;

    int count = 0;
    likes.values.forEach((val) {
      count += 1;
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: {"likes": this.likes},
      likeCount: getlikeCounts(this.likes));
}

class _PostState extends State<Post> {
  final String CurrentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;
  int likeCount;
  bool isLiked;
  bool showHeart = false;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount});

  buildPostHeader() {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.document(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  backgroundColor: Colors.grey,
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(location),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    print("delete");
                  },
                ),
              ),
              Container(
                child: Text(description),
              )
            ],
          );
        });
  }

  buildPostImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            handleLikePosts();
          },
          child: CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
            height: 300.0,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        showHeart
            ? Animator(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: Tween(begin: 0.8, end: 1.4),
                cycles: 0,
                builder: (context, anim, child) => Transform.scale(
                  scale: anim.value,
                  child: Icon(Icons.favorite, size: 170.0, color: Colors.red),
                ),
              )
            : Text(''),
      ],
    );
  }

  handleLikePosts() {
    bool isLiked = likes[CurrentUserId] == true;
    if (isLiked) {
      postsRef
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({'likes.$CurrentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[CurrentUserId] = false;
      });
    } else if (!isLiked) {
      postsRef
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({'likes.$CurrentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[CurrentUserId] = true;
        showHeart = true;
      });
    }
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  addLikeToActivityFeed() {
    feedsRef
        .document(ownerId)
        .collection("feedItems")
        .document(postId)
        .setData({
      "type": "like",
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
    });
  }

  removeLikeFromActivityFeed() {
    feedsRef
        .document(ownerId)
        .collection("feedItems")
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Divider(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      handleLikePosts();
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20.0,
                          color: Colors.pink,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Like"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      showComment(context,
                          postId: postId, ownerId: ownerId, mediaUrl: mediaUrl);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Comment"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Share"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = likes[CurrentUserId] == true;
    return Container(
      child: Column(
        children: [
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}

showComment(context, {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(postId: postId, ownerId: ownerId, mediaUrl: mediaUrl);
  }));
}
