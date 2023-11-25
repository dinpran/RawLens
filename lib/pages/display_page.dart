import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/auth/storage_services.dart';
import 'package:vidventure/pages/followers_page.dart';
import 'package:vidventure/pages/following_page.dart';
import 'package:vidventure/pages/login_page.dart';
import 'package:vidventure/pages/search_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class DisplayPage extends StatefulWidget {
  final String username;
  final String uid;
  DisplayPage({super.key, required this.username, required this.uid});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  var urlDownload;
  Stream<QuerySnapshot>? images;
  late List<String> _imageUrls = [];
  int followers = 0;
  int posts = 0;
  int following = 0;
  late List<String> _followers = [];
  late List<String> _following = [];
  bool isJoined = false;

  void initState() {
    super.initState();
    _loadImages();
    _checkUserExistence();
    _getImages();
    _getFollowingCount();
    joinedorNot(widget.uid);
  }

  Future<void> _loadImages() async {
    final StorageService _storageService = StorageService(uid: widget.uid);
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _getImages() async {
    final StorageService _storageService = StorageService(uid: widget.uid);
    List<String> imageUrls = await _storageService.listAllImages();
    setState(() {
      posts = imageUrls.length;
    });
  }

  Future<void> _checkUserExistence() async {
    int userExists = await DatabaseServices().getFollowersCount(widget.uid);
    setState(() {
      followers = userExists;
    });
  }

  Future<void> _getFollowingCount() async {
    int userExists = await DatabaseServices().getFollowingsCount(widget.uid);
    setState(() {
      following = userExists;
    });
  }

  joinedorNot(String groupId) {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupId)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  nextScreen(context, FollowersPage(uid: widget.uid));
                },
                child: Column(
                  children: [
                    Text(
                      "Followers",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("${followers}")
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    "Posts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${posts}")
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      nextScreen(context, FollowingPage(uid: widget.uid));
                    },
                    child: Text(
                      "Following",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("${following}")
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () async {
              await DatabaseServices(
                      uid: FirebaseAuth.instance.currentUser!.uid)
                  .toggleGroupJoin(
                widget.uid,
              );
              if (isJoined) {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackBar(context, Colors.red, "Unfollowing");
              } else {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackBar(context, Colors.green, "Successfully Following");
              }
            },
            child: isJoined
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(
                        child: const Text(
                          "Following",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Center(
                        child: const Text("Follow",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 15,
          ),
          _imageUrls == null
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of images in each row
                        crossAxisSpacing:
                            4.0, // Spacing between each image horizontally
                        mainAxisSpacing:
                            4.0, // Spacing between each image vertically
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        int reversedIndex = _imageUrls.length - 1 - index;
                        return Image.network(
                          _imageUrls[reversedIndex],
                          fit: BoxFit.cover, // Adjust the image's fit as needed
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
