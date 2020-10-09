import 'package:Fluttergram/feed.dart';
import 'package:Fluttergram/reels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("insta_posts").get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<DocumentSnapshot> data = snapshot.data.docs;
              if (data.length <= 0) {
                data.retainWhere((e) => e['mediaUrl'].toString().contains('mp4'));
                return PageView(
                  children: data.map((e) {
                    return Reels(
                        url: e['mediaUrl'],
                        username: e['username'],
                        description: e['description']);
                  }).toList(),
                );
              } else {
                return Center(child: Text('No reels'));
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
