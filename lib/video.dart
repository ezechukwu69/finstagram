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
  Video({Key key,this.url}):super(key: key);
  _Video createState() => _Video();
}

class _Video extends State<Video> with AutomaticKeepAliveClientMixin<Video> {
  VideoPlayerController _controller;
  int count = 0;
  bool show = true;
  bool playing = false;
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      })..setLooping(true);
    super.initState();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => setState(() {
          if(playing) {
            _controller.pause();
          } else {
            _controller.play();
          }
          playing = !playing;
        }),
        child: VideoPlayer(_controller));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
