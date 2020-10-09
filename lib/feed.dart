import 'package:Fluttergram/chat_page.dart';
import 'package:Fluttergram/comments.dart';
import 'package:Fluttergram/profile_page.dart';
import 'package:Fluttergram/small_widgets/chat_icon.dart';
import 'package:Fluttergram/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'image_post.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  _Feed createState() => _Feed();
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  List<ImagePost> feedData;
  @override
  void initState() {
    super.initState();
    this._loadFeed();
  }

  buildFeed() {
    if (feedData != null) {
      return ListView(
        children: [
          FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('insta_users')
                  .where("admin", isEqualTo: true)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.isNotEmpty) {
                    QueryDocumentSnapshot data = snapshot.data.docs.first;
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('/insta_posts')
                          .where('ownerId', isEqualTo: data['id'])
                          .orderBy("timestamp",descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null && snapshot.data.docs.length > 0) {
                            QueryDocumentSnapshot e = snapshot.data.docs.first;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.grey[300]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Featured",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .doc('/insta_users/${e['ownerId']}')
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 20.0,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                      child: Image.network(
                                                        snapshot.data['photoUrl'],
                                                        fit: BoxFit.fill,
                                                      )),
                                                );
                                              }
                                              return CircleAvatar(
                                                  child: Container());
                                            }),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            e['username'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    !e['mediaUrl'].contains('mp4')
                                        ? Container(
                                        height:
                                        MediaQuery.of(context).size.height /
                                            1.9,
                                        width:
                                        MediaQuery.of(context).size.width,
                                        child: Image.network(
                                          e['mediaUrl'],
                                          fit: BoxFit.cover,
                                        ))
                                        : Container(
                                      height:
                                      MediaQuery.of(context).size.height /
                                          1.9,
                                      width:
                                      MediaQuery.of(context).size.width,
                                      child: Stack(
                                        children: [
                                          Video(url: e['mediaUrl']),
                                          Positioned(
                                              bottom: 8.0,
                                              right: 8.0,
                                              child: Icon(Icons
                                                  .movie_creation_outlined))
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .doc(
                                                  '/insta_posts/${e['postId']}')
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return IconButton(
                                                      icon: snapshot.data['likes']
                                                          .contains(
                                                          "${googleSignIn.currentUser.id}")
                                                          ? Icon(
                                                          CupertinoIcons
                                                              .heart_fill,
                                                          color: Colors.red)
                                                          : Icon(
                                                          CupertinoIcons.heart,
                                                          color: Colors.black),
                                                      onPressed: () async {
                                                        FirebaseFirestore.instance
                                                            .doc(
                                                            '/insta_posts/${e['postId']}')
                                                            .get()
                                                            .then((value) async {
                                                          if (value
                                                              .data()['likes']
                                                              .contains(
                                                              "${googleSignIn.currentUser.id}")) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .doc(
                                                                '/insta_posts/${e['postId']}')
                                                                .update({
                                                              "likes": FieldValue
                                                                  .arrayRemove([
                                                                '${googleSignIn.currentUser.id}'
                                                              ])
                                                            });
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .doc(
                                                                '/insta_posts/${e['postId']}')
                                                                .update({
                                                              "likes": FieldValue
                                                                  .arrayUnion([
                                                                '${googleSignIn.currentUser.id}'
                                                              ])
                                                            });
                                                          }
                                                          setState(() {});
                                                        });
                                                      });
                                                }
                                                return Icon(CupertinoIcons.heart);
                                              }),
                                          IconButton(
                                              icon: Icon(CupertinoIcons
                                                  .conversation_bubble),
                                              onPressed: e['ownerId'] == googleSignIn.currentUser.id
                                                  ? null
                                                  : () {
                                                FirebaseFirestore.instance
                                                    .collection('insta_chats')
                                                    .where('participants',
                                                    arrayContains:
                                                    e['ownerId'])
                                                    .get()
                                                    .then((value) {
                                                  List<QueryDocumentSnapshot>
                                                  dt = value.docs;
                                                  if (dt.isEmpty) {
                                                    DocumentReference dt =
                                                    FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                        'insta_chats')
                                                        .doc();
                                                    dt.set({
                                                      'participants': [
                                                        googleSignIn.currentUser.id,
                                                        e['ownerId']
                                                      ],
                                                      'chats': []
                                                    }).then((value) => Navigator
                                                        .of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                ChatPage(
                                                                  ownerId:
                                                                  e['ownerId'],
                                                                  chatId:
                                                                  dt.id,
                                                                ))));
                                                  } else {
                                                    dt.map((a) => a[
                                                    'participants']
                                                        .contains(
                                                        e['ownerId']));
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                        'insta_chats')
                                                        .doc('${dt.first.id}')
                                                        .get()
                                                        .then((value) => Navigator
                                                        .of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatPage(
                                                                  ownerId:
                                                                  e['ownerId'],
                                                                  chatId:
                                                                  value.id,
                                                                ))));
                                                  }
                                                });
                                              })
                                        ]),
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .doc('/insta_posts/${e['postId']}')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data['likes'].length ==
                                                  1) {
                                                return Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "${snapshot.data['likes'].length} like",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.grey[800])),
                                                );
                                              } else {
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "${snapshot.data['likes'].length} likes",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.grey[800])),
                                                );
                                              }
                                            }
                                            return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "${e['likes'].length} likes",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey[800])));
                                          },
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(e['description'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => CommentsPage(
                                                postId: e['postId'],
                                              ),
                                            ));
                                          },
                                          child: StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("comments")
                                                  .doc('${e['postId']}')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data.exists) {
                                                    return Text(
                                                        '${snapshot.data['comments'].length} comments');
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection("comments")
                                                        .doc('${e['postId']}')
                                                        .set({'comments': []});
                                                    return Text('0 comments');
                                                  }
                                                }
                                                return Text('0 comments');
                                              })),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }

                        }
                        return Container();
                      },
                    );
                  }
                }
                return Container();
              }),
          ...feedData.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => openProfile(context, e.ownerId),
                      child: Row(children: [
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .doc('/insta_users/${e.ownerId}')
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20.0,
                                  backgroundImage: NetworkImage(snapshot.data['photoUrl']));
                              }
                              return CircleAvatar(child: Container());
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            e.username,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  !e.mediaUrl.contains('mp4')
                      ? Container(
                          height: MediaQuery.of(context).size.height / 1.9,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            e.mediaUrl,
                            fit: BoxFit.cover,
                          ))
                      : Container(
                          height: MediaQuery.of(context).size.height / 1.9,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Video(url: e.mediaUrl),
                              Positioned(
                                  bottom: 8.0,
                                  right: 8.0,
                                  child: Icon(Icons.movie_creation_outlined))
                            ],
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .doc('/insta_posts/${e.postId}')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> data = snapshot.data['likes'];
                                return IconButton(
                                    icon: snapshot.data['likes']
                                            .contains("${googleSignIn.currentUser.id}")
                                        ? Icon(CupertinoIcons.heart_fill,
                                            color: Colors.red)
                                        : Icon(CupertinoIcons.heart,
                                            color: Colors.black),
                                    onPressed: () async {
                                      FirebaseFirestore.instance
                                          .doc('/insta_posts/${e.postId}')
                                          .update({
                                        "likes" : data.contains('${googleSignIn.currentUser.id}') ? FieldValue.arrayRemove([
                                          '${googleSignIn.currentUser.id}'
                                        ]) : FieldValue.arrayUnion([
                                          '${googleSignIn.currentUser.id}'
                                        ])
                                      });
                                          setState(() {});
                                      });
                              }
                              return Icon(CupertinoIcons.heart);
                            }),
                        IconButton(
                            icon: Icon(CupertinoIcons.conversation_bubble),
                            onPressed: e.ownerId == googleSignIn.currentUser.id
                                ? null
                                : () {
                                    FirebaseFirestore.instance
                                        .collection('insta_chats')
                                        .where('participants',
                                            arrayContains: e.ownerId)
                                        .get()
                                        .then((value) {
                                      List<QueryDocumentSnapshot> dt =
                                          value.docs;
                                      if (dt.isEmpty) {
                                        DocumentReference dt = FirebaseFirestore
                                            .instance
                                            .collection('insta_chats')
                                            .doc();
                                        dt.set({
                                          'participants': [googleSignIn.currentUser.id, e.ownerId],
                                          'chats': []
                                        }).then((value) => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                      ownerId: e.ownerId,
                                                      chatId: dt.id,
                                                    ))));
                                      } else {
                                        dt.map((a) => a['participants']
                                            .contains(e.ownerId));
                                        FirebaseFirestore.instance
                                            .collection('insta_chats')
                                            .doc('${dt.first.id}')
                                            .get()
                                            .then((value) =>
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatPage(
                                                              ownerId:
                                                                  e.ownerId,
                                                              chatId: value.id,
                                                            ))));
                                      }
                                    });
                                  })
                      ]),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .doc('/insta_posts/${e.postId}')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            String likes = snapshot.data['likes'].length == 1 ? 'like' : 'likes';
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "${snapshot.data['likes'].length} ${ likes }",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800])),
                              );
                            }
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("0 likes",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800])));
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(e.description,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800])),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentsPage(
                              postId: e.postId,
                            ),
                          ));
                        },
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("comments")
                                .doc('${e.postId}')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.exists) {
                                  return Text(
                                      '${snapshot.data['comments'].length} comments');
                                } else {
                                  FirebaseFirestore.instance
                                      .collection("comments")
                                      .doc('${e.postId}')
                                      .set({'comments': []});
                                  return Text('0 comments');
                                }
                              }
                              return Text('0 comments');
                            })),
                  )
                ],
              ),
            );
          }).toList()
        ],
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finstagram',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [ChatIcon()],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: buildFeed(),
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();

    setState(() {});

    return;
  }

  _loadFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String json = prefs.getString("feed");

    // if (json != null) {
    //   List<dynamic> data = [];
    //   List<ImagePost> listOfPosts = [];
    //   try {
    //     if (json.length > 0) {
    //       data = await jsonDecode(json);
    //       print("data check : ${data.toString()}");
    //       listOfPosts = _generateFeed(data);
    //       // print("List of posts: ${listOfPosts.first.description}");
    //       setState(() {
    //         feedData = listOfPosts;
    //       });
    //     }
    //   } catch (e) {
    //     print("Load error: $e");
    //   }
    // } else {
      _getFeed();
    // }
  }

  _getFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration(seconds: 1));
    var url =
        'https://us-central1-finstagram-57d3b.cloudfunctions.net/getFeed?uid=' +
            googleSignIn.currentUser.id;
    var httpClient = HttpClient();

    List<ImagePost> listOfPosts = [];
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("feed", json);
        List<dynamic> data;
        try {
          data = await jsonDecode(json);
          listOfPosts = _generateFeed(data);
          result = "Success in http request for feed";
        } catch (e) {
          print("Error e: $e");
        }
      } else {
        result =
            'Error getting a feed: Http status ${response.statusCode} | userId ${googleSignIn.currentUser.id}';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    setState(() {
      feedData = listOfPosts;
    });
  }

  List<ImagePost> _generateFeed(dynamic feedData) {
    List<ImagePost> listOfPosts = [];
    try {
      for (var postData in feedData) {
        listOfPosts.add(ImagePost.fromJSON(postData));
      }
    } catch (e) {
      print("Error _generate Feed: $e");
    }

    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
