import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vidventure/auth/database_services.dart';
import 'package:vidventure/pages/display_page.dart';
import 'package:vidventure/pages/getfollowers_page.dart';
import 'package:vidventure/pages/getfollowing_page.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/pages/userprofile_page.dart';
import 'package:vidventure/widgets/widgets.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  late Future<List<Map<String, dynamic>>> discoverUsersFuture;

  @override
  void initState() {
    super.initState();
    discoverUsersFuture =
        DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .getDiscoverUsers(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Discover People",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: discoverUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No users to discover."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userData = snapshot.data![index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      // Choose the color you prefer
                      child: Text(
                        userData['fullname'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(userData['fullname']),
                    onTap: () {
                      // Navigate to the DisplayPage and pass user data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPage(
                            username: userData['fullname'],
                            uid: userData['uid'],
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            left: 16, right: 16, bottom: 16), // Adds spacing
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(30), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                blurRadius: 10, // Softness of the shadow
                spreadRadius: 2, // Shadow spread
                offset: Offset(0, 4), // Shadow position
              ),
            ],
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 18), // Padding inside navbar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(context, HomePage());
                },
                child: Icon(Icons.home),
              ),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(
                    context,
                    GetFollowingPage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  );
                },
                child: Icon(Icons.favorite),
              ),
              GestureDetector(
                onTap: () {
                  nextScreenReplacement(
                    context,
                    GetFollowersPage(
                        uid: FirebaseAuth.instance.currentUser!.uid),
                  );
                },
                child: Icon(Icons.people),
              ),
              Icon(Icons.explore, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
