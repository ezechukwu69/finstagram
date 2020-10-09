import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Reels extends StatefulWidget {
  final String url;
  final String description;
  final String username;

  Reels(
      {@required this.url,
      @required this.username,
      @required this.description});
  @override
  _ReelsState createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
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
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (count % 2 == 0) {
                _controller.play();
              } else {
                _controller.pause();
              }
            });
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayer(_controller)),
        ),
        Positioned(
          top: 25.0,
          left: 12.0,
          child: Text(
            "${widget.username}",
            style: TextStyle(fontSize: 25.0,color: Colors.grey),
          ),
        ),
        Positioned(
          bottom: 12.0,
          left: 12.0,
          child: Text("${widget.description}", style: TextStyle(fontSize: 14.0,color: Colors.blue[200])),
        ),
      ],
    );
  }
}
