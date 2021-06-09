import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialchat/models/user.dart';
import 'package:socialchat/pages/home.dart';
import 'package:socialchat/pages/profile.dart';
import 'package:socialchat/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController txtSearch = TextEditingController();
  Future<QuerySnapshot> searchResult;

  handleSearch(value) {
    Future<QuerySnapshot> users = usersRef
        .where('username', isGreaterThanOrEqualTo: value)
        .getDocuments();
    setState(() {
      searchResult = users;
    });
  }

  clearSearch() {
    txtSearch.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
        backgroundColor: Colors.white,
        title: Container(
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30.0)),
          child: TextFormField(
            controller: txtSearch,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search for a user',
              prefixIcon: Icon(Icons.account_box),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  clearSearch();
                },
              ),
            ),
            onFieldSubmitted: (value) {
              handleSearch(value);
            },
          ),
        ));
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            height: orientation == Orientation.portrait ? 300 : 200,
          ),
          Text(
            'Find User',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          )
        ],
      ),
    ));
  }

  buildResultSearch() {
    return FutureBuilder<QuerySnapshot>(
      future: searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<userResult> searchdata = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          searchdata.add(userResult(
            user: user,
          ));
        });
        return ListView(
          children: searchdata,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: buildSearchField(),
      body: searchResult != null ? buildResultSearch() : buildNoContent(),
    ));
  }
}

class userResult extends StatelessWidget {
  final User user;

  userResult({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
return new Profile(profileId: user.id,);
                }));
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(user.displayName,
                    style: TextStyle(
                      color: Colors.grey,
                    )),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
