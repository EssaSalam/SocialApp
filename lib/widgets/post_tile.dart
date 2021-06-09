import 'package:flutter/material.dart';
import 'package:socialchat/pages/custom_image.dart';
import 'package:socialchat/widgets/posts.dart';

class PostTile extends StatefulWidget {
  final Post post;
PostTile({this.post});
  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

      },
      child: cachedNetworkImage(widget.post.mediaUrl),
    );
  }
}
