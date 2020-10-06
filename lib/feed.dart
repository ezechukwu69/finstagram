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
        children: feedData.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .doc('/insta_users/${e.ownerId}')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              radius: 20.0,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: Image.network(
                                    snapshot.data['photoUrl'],
                                    fit: BoxFit.fill,
                                  )),
                            );
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
                Container(
                    height: MediaQuery.of(context).size.height / 1.9,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      e.mediaUrl,
                      fit: BoxFit.cover,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FutureBuilder(
                            future: FirebaseFirestore.instance
                                .doc('/insta_posts/${e.postId}')
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return IconButton(
                                    icon: snapshot.data['likes']
                                            .contains("${user.id}")
                                        ? Icon(CupertinoIcons.heart_fill,
                                            color: Colors.red)
                                        : Icon(CupertinoIcons.heart,
                                            color: Colors.black),
                                    onPressed: () async {
                                      FirebaseFirestore.instance
                                          .doc('/insta_posts/${e.postId}')
                                          .get()
                                          .then((value) async {
                                        if (value
                                            .data()['likes']
                                            .contains("${user.id}")) {
                                          await FirebaseFirestore.instance
                                              .doc('/insta_posts/${e.postId}')
                                              .update({
                                            "likes": FieldValue.arrayRemove(
                                                ['${user.id}'])
                                          });
                                        } else {
                                          await FirebaseFirestore.instance
                                              .doc('/insta_posts/${e.postId}')
                                              .update({
                                            "likes": FieldValue.arrayUnion(
                                                ['${user.id}'])
                                          });
                                        }
                                        setState(() {});
                                      });
                                    });
                              }
                              return Icon(CupertinoIcons.heart);
                            }),
                        IconButton(
                            icon: Icon(CupertinoIcons.conversation_bubble),
                            onPressed: () {}),
                      ],
                    ),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .doc('/insta_posts/${e.postId}')
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data['likes'].length <= 1) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${snapshot.data['likes'].length} like",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                            );
                          } else {
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${snapshot.data['likes'].length} likes",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                            );
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${e.likes.length} likes",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800])),
                        );
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(e.description,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800])),
                ),
              ],
            ),
          );
        }).toList(),
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
        title: const Text('Fluttergram',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
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
    String json = prefs.getString("feed");

    if (json != null) {
      List<dynamic> data;
      List<ImagePost> listOfPosts;
      try {
        data = jsonDecode(json);
        print(data.toString());
        for (var data in data) {
          listOfPosts = _generateFeed(data);
          print("List of posts: ${listOfPosts.first.description}");
        }
        setState(() {
          feedData = listOfPosts;
        });
      } catch (e) {
        print("Load error: $e");
      }
    } else {
      _getFeed();
    }
  }

  _getFeed() async {
    print("Staring getFeed");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = googleSignIn.currentUser.id.toString();
    var url =
        'https://us-central1-finstagram-57d3b.cloudfunctions.net/getFeed?uid=' +
            userId;
    var httpClient = HttpClient();

    List<ImagePost> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        print("json: $json");
        prefs.setString("feed", json);
        List<dynamic> data;
        try {
          data = jsonDecode(json);
          print(data.toString());
          for (var data in data) {
            listOfPosts = _generateFeed(data);
            print("List of posts: ${listOfPosts.first.description}");
          }
          result = "Success in http request for feed";
        } catch (e) {
          print("Error e: $e");
        }
      } else {
        result =
            'Error getting a feed: Http status ${response.statusCode} | userId $userId';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

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
