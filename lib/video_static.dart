import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:video_player/video_player.dart';
import 'image_post.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Video extends StatefulWidget {
  final String url;
  Video({this.url});
  _Video createState() => _Video();
}

class _Video extends State<Video> with AutomaticKeepAliveClientMixin<Video> {
  VideoPlayerController _controller;
  int count = 0;
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            if (count % 2 == 0) {
              _controller.play();
            } else {
              _controller.pause();
            }
          });
        },
        child: VideoPlayer(_controller));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
