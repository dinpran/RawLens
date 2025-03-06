import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vidventure/auth/auth_services.dart';
import 'package:vidventure/pages/home_page.dart';
import 'package:vidventure/widgets/widgets.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  String username;
  String email;
  ProfilePage({super.key, required this.username, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthServices authService = AuthServices();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initBannerAd();
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: 'ca-app-pub-8996334303873561/3087234311',
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                _isAdLoaded = true;
              });
            },
            onAdFailedToLoad: ((ad, error) {})),
        request: AdRequest());
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              width: 150, // Icon width
              height: 150, // Icon height
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50
                  ], // Apply gradient here
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100, // Icon size
                  color:
                      Colors.white, // Icon color will remain white to stand out
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.username,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                nextScreen(context, HomePage());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Home",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: Text(
                "Profile",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () async {
                await authService.signout();
                nextScreenReplacement(context, LoginPage());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.logout),
              title: Text(
                "Logout",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          padding: EdgeInsets.symmetric(vertical: 50),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 200, // Icon width
                height: 200, // Icon height
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.purple.shade50
                    ], // Apply gradient here
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 100, // Icon size
                    color: Colors
                        .white, // Icon color will remain white to stand out
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Full Name",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.username,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.email,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isAdLoaded
          ? Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : SizedBox(),
    );
  }
}
