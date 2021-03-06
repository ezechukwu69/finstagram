import 'package:Fluttergram/reels_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'feed.dart';
import 'upload_page.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'create_account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'models/user.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
final ref = FirebaseFirestore.instance.collection('insta_users');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

UserModel currentUserModel;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // after upgrading flutter this is now necessary
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings;
  runApp(Fluttergram());
}

Future<Null> _ensureLoggedIn(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;

  if (user == null) {
    await googleSignIn.signIn();
    await tryCreateUserRecord(context);
  }

  if (auth.currentUser == null) {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);
    user = googleUser;
  }
}

Future<Null> _silentLogin(BuildContext context) async {


  if (googleSignIn.currentUser == null) {
    await googleSignIn.signInSilently();
    await tryCreateUserRecord(context);
  }

  if (auth.currentUser == null && googleSignIn.currentUser != null) {
    googleSignIn.currentUser.clearAuthCache();
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);
  }
}

Future<Null> _setUpNotifications() async {
  if (Platform.isAndroid) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: " + token);

      FirebaseFirestore.instance
          .collection("insta_users")
          .doc(currentUserModel.id)
          .update({"androidNotificationToken": token});
    });
  }
}

Future<void> tryCreateUserRecord(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    return null;
  }
  DocumentSnapshot userRecord = await ref.doc(user.id).get();
  if (!userRecord.exists) {

    String userName = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Center(
                child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: Text('Fill out missing data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: ListView(
                      children: <Widget>[
                        Container(
                          child: CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0) {
      await ref.doc(user.id).set({
        "id": user.id,
        "username": userName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "followers": {},
        "following": {},
        "admin": false
      });
    }
    userRecord = await ref.doc(user.id).get();
    currentUserModel = await UserModel.fromDocument(userRecord);
  }
  currentUserModel = await UserModel.fromDocument(userRecord);

}

class Fluttergram extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      // key: UniqueKey(),
      title: 'Finstagram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          buttonColor: Colors.pink,
          primaryIconTheme: IconThemeData(color: Colors.black)),
      home: HomePage(title: 'Finstagram'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

PageController pageController;

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool triedSilentLogin = false;
  bool setupNotifications = false;

  Scaffold buildLoginPage() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 240.0),
          child: Column(
            children: <Widget>[
              Text(
                'Finstagram',
                style: TextStyle(
                    fontSize: 60.0,
                    fontFamily: "Billabong",
                    color: Colors.black),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 100.0)),
              GestureDetector(
                onTap: login,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    width: 250.0,
                    child: Image.asset(
                      "assets/images/google_signin_button.png",
                      width: 225.0,
                      // fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      silentLogin(context);
    }

    if (setupNotifications == false && currentUserModel != null) {
      setUpNotifications();
    }

    return (googleSignIn.currentUser == null || currentUserModel == null)
        ? buildLoginPage()
        : Scaffold(
            body: PageView(
              children: [
                Container(
                  color: Colors.white,
                  child: Feed(),
                ),
                Container(color: Colors.white, child: SearchPage()),
                Container(
                  color: Colors.white,
                  child: Uploader(),
                ),
                // Container(color: Colors.white, child: ActivityFeedPage()),
                Container(color: Colors.white, child: ReelsPage()),
                Container(
                    color: Colors.white,
                    child: ProfilePage(
                      userId: googleSignIn.currentUser.id,
                    )),
              ],
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: CupertinoTabBar(
              backgroundColor: Colors.white,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home,
                        color: (_page == 0) ? Colors.black : Colors.grey),
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search,
                        color: (_page == 1) ? Colors.black : Colors.grey),
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle,
                        color: (_page == 2) ? Colors.black : Colors.grey),
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.movie,
                        color: (_page == 3) ? Colors.black : Colors.grey),
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person,
                        color: (_page == 4) ? Colors.black : Colors.grey),
                    backgroundColor: Colors.white),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          );
  }

  void login() async {
    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void setUpNotifications() {
    _setUpNotifications();
    setState(() {
      setupNotifications = true;
    });
  }

  void silentLogin(BuildContext context) async {
    await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
