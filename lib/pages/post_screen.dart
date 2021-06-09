import 'package:flutter/material.dart';
import 'package:socialchat/pages/home.dart';
import 'package:socialchat/widgets/header.dart';
import 'package:socialchat/widgets/posts.dart';
import 'package:socialchat/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection("usersPosts")
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        if (snapshot.data != null) {
          Post post = Post.fromDocument(snapshot.data);
          return Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          );
        } else {
          return Text("");
        }
      },
    );
  }
}
