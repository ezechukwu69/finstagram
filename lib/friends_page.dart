import 'package:Fluttergram/chat_page.dart';
import 'package:Fluttergram/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool isTrue = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Friends',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('insta_users')
              .doc(googleSignIn.currentUser.id)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> usr = [];
              Set<String> users;
              Map<String,dynamic> dt1 = snapshot.data['following'];
              Map<String,dynamic> dt2 = snapshot.data['followers'];
              dt1.forEach((k, v) { 
                if (v == true) {
                  usr.add(k);
                }
              });
              dt2.forEach((k, v) {
                if (v == true) {
                  usr.add(k);
                }
              });
              usr.sort((a,b) => (b.substring(0,0)).compareTo((a.substring(0,0))));
              users = usr.toSet();
              print(users.toString());
              return ListView(
                children: users.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Card(
                      child: GestureDetector(
                        onTap:  () {
                          FirebaseFirestore
                              .instance
                              .collection("insta_chats")
                              .where('participants',arrayContains: e)
                              .get()
                              .then((value) {
                                List<QueryDocumentSnapshot> qsd = value.docs;
                                if (qsd.isNotEmpty) {
                                  qsd.removeWhere((el) => el['participants'].contains(googleSignIn.currentUser.id));
                                  print(qsd.length.toString());
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(ownerId: e,chatId: qsd.first.id,)));
                                } else {
                              DocumentReference dt = FirebaseFirestore.instance.collection('insta_chats').doc();
                              dt.set({
                                'participants': [googleSignIn.currentUser.id,e],
                                'chats': []
                              }).then((value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(ownerId: e,chatId: dt.id,))));
                            }
                          });
                        },
                        child: ListTile(
                          leading: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('insta_users')
                                  .doc(e)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(snapshot.data['photoUrl']), );}
                                return CircleAvatar(child: Container(),);
                              }),
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('insta_users')
                                        .doc(e)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text("${snapshot.data['username']}",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),);
                                      }
                                      return Container();
                                    }
                                ),
                        ]),
                      ),
                    ),
                  ));
                }).toList(),
              );
            }
            return Center(child: Text('No chats'));
          }),
    );
  }
}
