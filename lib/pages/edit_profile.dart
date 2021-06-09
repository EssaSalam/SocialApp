import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialchat/models/user.dart';
import 'package:socialchat/pages/home.dart';
import 'package:socialchat/widgets/header.dart';
import 'package:socialchat/widgets/progress.dart';
class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}
class _EditProfileState extends State<EditProfile> {
  User user;
  bool isLoadding = false;
  TextEditingController controllerDisplayName = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
bool _validBio=true;
bool _validDisplayName=true;
final _scaffKey=GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoadding = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    controllerDisplayName.text=user.displayName;
    controllerBio.text=user.bio;
    setState(() {
      isLoadding = false;
    });
  }

  Container textFieldDisplayName() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Display Name", style: TextStyle(color: Colors.grey),),
              ),
              TextField(
                controller: controllerDisplayName,
                decoration: InputDecoration(
                    hintText: "Update Display Name",
                    errorText:_validDisplayName?null:'Display name too Short'
                ),
              )
            ]));
  }

  textFieldBio() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Bio", style: TextStyle(color: Colors.grey),),
              ),
              TextField(
                controller: controllerBio,
                decoration: InputDecoration(
                    hintText: "Update Bio",
                  errorText:_validBio?null:'Bio too Long'
                ),
              )
            ]));
  }
updateProfileData(){
    setState(() {
      controllerDisplayName.text.trim().length<3 ||
      controllerDisplayName.text.isEmpty ?
      _validDisplayName=false
          :true;

      controllerBio.text.trim().length>100?
      _validBio=false:true;

    });
    if(_validDisplayName&&_validBio){
      usersRef.document(widget.currentUserId).updateData({
        'displayName':controllerDisplayName.text,
        'bio':controllerBio.text,
      });
    }
    SnackBar snackBar=SnackBar(content: Text('Profile Update'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // _scaffKey.currentState.showSnackBar(snackBar);
}
  _logoutAccount()async{
await googleSignIn.signOut();
Navigator.push(context, MaterialPageRoute(builder: (context){
  return Home();
}));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: _scaffKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Edit Profile'),
          actions: [
            IconButton(icon: Icon(Icons.done),
                onPressed: () {
Navigator.pop(context);
                }
            )
          ],
        ),
        body: isLoadding ? circularProgress() : ListView(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                textFieldDisplayName(),
                textFieldBio(),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    child: Text('Update Profile', style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    ),),
                    onPressed: () {
                      updateProfileData();
                    }
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                TextButton.icon(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  label: Text('logout', style: TextStyle(
                      color: Colors.red, fontSize: 25.0
                  ),),
                  onPressed: () {
_logoutAccount();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}