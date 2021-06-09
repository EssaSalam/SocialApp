import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socialchat/models/user.dart';
import 'package:image/image.dart' as Im;
import 'package:socialchat/widgets/progress.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  bool isUploading = false;
  File file;
  TextEditingController textPost = TextEditingController();
  TextEditingController textGeolocator = TextEditingController();
  String postId = Uuid().v4();

  handelCamera() async {
    File _image;
    final picker = ImagePicker();

    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    // await ImagePicker.pickImage(
    //     source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        this.file = _image;
      } else {
        print('No image selected.');
      }
    });
    // Navigator.pop(context);
    // File file = await ImagePicker.pickImage(
    //     source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960.0);
    // setState(() {
    //   this.file = file;
    // });
  }

  handelGallery() async {
    File _image;
    final picker = ImagePicker();

    Navigator.pop(context);
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    // await ImagePicker.pickImage(
    //     source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960.0);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        this.file = _image;
      } else {
        print('No image selected.');
      }
    });
    // Navigator.pop(context);
    // File file = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, maxHeight: 675.0, maxWidth: 960.0);
    // setState(() {
    //   this.file = file;
    // });
  }

  compressImage() async {
    final tmpDir = await getTemporaryDirectory();
    final path = tmpDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressImageFile;
    });
  }

  uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  chooseImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handelCamera,
              ),
              SimpleDialogOption(
                child: Text('Photo from Gallery'),
                onPressed: handelGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  createPostFirestore({String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection('usersPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  buildSplashScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 200.0,
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () {
                chooseImage(context);
              })
        ],
      ),
    );
  }

  handelSubmit() async {
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
    await compressImage();
    String mediuUrl = await uploadImage(file);
    createPostFirestore(
        mediaUrl: mediuUrl,
        location: textGeolocator.text,
        description: textPost.text);
    setState(() {
      textGeolocator.clear();
      textPost.clear();
    });
  }

  buildForm(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () {
                  handelSubmit();
                },
                child: Text(
                  "Post",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ))
          ],
          title: Text('UploadPost', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Navigator.pop(context);
              setState(() {
                file = null;
              });
            },
          ),
        ),
        body: ListView(
          children: [
            isUploading ? linearProgress() : Text(''),
            Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(file),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.currentUser.photoUrl),
              ),
              title: TextField(
                controller: textPost,
                decoration: InputDecoration(
                    hintText: "Write here post", border: InputBorder.none),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            ListTile(
              leading: Icon(
                Icons.pin_drop,
                color: Colors.orange,
                size: 35.0,
              ),
              title: TextField(
                controller: textGeolocator,
                decoration: InputDecoration(
                    hintText: "Where was This taken", border: InputBorder.none),
              ),
            ),
            Container(
                width: 100.0,
                padding: EdgeInsets.all(60.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      primary: Theme.of(context).primaryColor),
                  onPressed: () {
                    getUserLocation();
                  },
                  icon: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Use Current location',
                    style: TextStyle(color: Colors.white),
                  ),
                ))
          ],
        ));
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print('FullAddress is: ${placemark}');

    String fullAddress = "${placemark.locality}" + "," + "${placemark.country}";
    print('FullAddress is: ${fullAddress}');
    textGeolocator.text = fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    // if(file == null){
    //   return buildSplashScreen();
    // } else{
    //   return buildForm();
    // }
    return file == null ? buildSplashScreen(context) : buildForm(context);
  }
}
