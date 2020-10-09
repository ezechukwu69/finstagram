import 'package:Fluttergram/chats_page.dart';
import 'package:flutter/material.dart';

class ChatIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(Icons.send_outlined), onPressed: () {
      Navigator
          .of(context)
          .push(
          MaterialPageRoute(builder: (context) => ChatsPage(),)
      );
    });
  }
}
