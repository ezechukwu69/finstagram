import 'package:Fluttergram/chat_page.dart';
import 'package:Fluttergram/friends_page.dart';
import 'package:Fluttergram/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage({Key key}) : super(key: key);
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    if (googleSignIn.currentUser != null) {
      print(googleSignIn.currentUser.id);
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Chats',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('insta_chats')
                .where('participants', arrayContains: googleSignIn.currentUser.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                QuerySnapshot dt = snapshot.data;
                int dcs;
                if (dt.docs != null) {
                  dcs = dt.docs.length;
                }
                if (dcs > 0) {
                  return ListView(
                    children: dt.docs.map((e) {
                      List<dynamic> d = e['chats'];
                      String l_message;
                      if (d.isNotEmpty) {
                        d.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
                        l_message = d.last['message'];
                      }
                      List<dynamic> other = e['participants'];
                      other.removeWhere((element) => element == googleSignIn.currentUser.id);
                      // if (d.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            child: GestureDetector(
                              onTap: () => Navigator.
                              of(context)
                                  .push(MaterialPageRoute(builder: (context) => ChatPage(
                                chatId: e.id,
                                ownerId: other.first,
                              ),)),
                              child: ListTile(
                                leading: FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('insta_users')
                                        .doc(other.first)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return CircleAvatar(
                                          backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(snapshot.data['photoUrl']),);
                                      }
                                      return CircleAvatar(child: Container(),);
                                    }),
                                title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('insta_users')
                                              .doc(other.first)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text("${snapshot.data['username']}",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),);
                                            }
                                            return Container();
                                          }
                                      ),
                                      SizedBox(height: 9,),
                                      Text(l_message != null ? l_message :"")]),
                              ),
                            ),
                          ),
                        );
                      }
                      // else {
                      //   return Container();
                      // }
                    // }
                ).toList(),
                  );
                } else {
                  return Center(child: Text('No chats'));
                }
              }
              return Center(child: Text('No chats'));
            }),
        floatingActionButton: FloatingActionButton(
          onPressed:() => Navigator
          .of(context)
          .push(MaterialPageRoute(builder: (context) => FriendsPage(),)),
          child: Icon(Icons.add),
        ),
    );
  }
}
