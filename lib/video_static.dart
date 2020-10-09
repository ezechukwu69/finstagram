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

class VideoStatic extends StatefulWidget {
  final String url;
  VideoStatic({this.url});
  _VideoStatic createState() => _VideoStatic();
}

class _VideoStatic extends State<VideoStatic> with AutomaticKeepAliveClientMixin<VideoStatic> {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(_controller);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
