import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/pages/display_page.dart';
import 'package:vidventure/pages/getfollowers_page.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/widgets/widgets.dart'; // Import your DisplayPage class

class FollowingPage extends StatefulWidget {
  final String uid;

  FollowingPage({required this.uid});

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late Future<List<DocumentSnapshot>> _followingInfo;

  @override
  void initState() {
    super.initState();
    _followingInfo = _getFollowingInfo();
  }

  Future<List<DocumentSnapshot>> _getFollowingInfo() async {
    DocumentSnapshot userSnapshot =
        await DatabaseServices(uid: widget.uid).getUserInfo(widget.uid);
    List<dynamic> following = userSnapshot['following'] ?? [];

    List<Future<DocumentSnapshot>> followingInfoFutures = [];
    for (var followingUid in following) {
      followingInfoFutures.add(DatabaseServices().getUserInfo(followingUid));
    }

    List<DocumentSnapshot> followingInfo =
        await Future.wait(followingInfoFutures);
    return followingInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _followingInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Not following anyone.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                int reversedIndex = snapshot.data!.length - 1 - index;
                var followingUser = snapshot.data![reversedIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(followingUser['fullname']),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Text(
                        followingUser['fullname'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPage(
                            username: followingUser['fullname'],
                            uid: followingUser['uid'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
