import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class ChatPage extends StatefulWidget {
  final String ownerId;
  final String chatId;
  ChatPage({Key key, this.ownerId,this.chatId}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller;
  FocusNode f = FocusNode();

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: FutureBuilder(
          future: FirebaseFirestore.instance.doc('/insta_users/${widget.ownerId}').get(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: Image.network(snapshot.data['photoUrl'],fit: BoxFit.contain,)),),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${snapshot.data['username']}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            }
            return Container();
          }
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => f.unfocus(),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("insta_chats")
                        .doc(widget.chatId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data['chats'].length > 0) {
                          List<dynamic> data = snapshot.data['chats'];
                          data.sort((a, b) =>
                              a['timestamp'].compareTo(b['timestamp']));
                          List<dynamic> other = snapshot.data['participants'];
                          other.removeWhere((element) => element == googleSignIn.currentUser.id);
                          return ListView(
                            children: data.map((e) {
                              print(e['user']);
                              print(googleSignIn.currentUser.id);
                              if (e['user'] != other.first) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.blue[400]),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                e['message'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                              } else {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.green[400]),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                e['message'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                              }
                            }).toList(),
                          );
                        } else {
                          return Center(
                            child: Text("No chats"),
                          );
                        }
                      }
                      return Center(
                        child: Text("No chats"),
                      );
                    })),
            Container(
                child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 3.0),
                  child: TextField(
                    focusNode: f,
                    onChanged: (e) {
                      setState(() {});
                    },
                    onSubmitted: (s) {
                      if (_controller.text.isNotEmpty &&
                          _controller.text.length > 1) {
                        FirebaseFirestore.instance
                            .collection('chats')
                            .where('participants',
                                arrayContains: [googleSignIn.currentUser.id, widget.ownerId])
                            .get()
                            .then((value) {
                              if (value.docs.first.exists) {
                                FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(value.docs.first.id)
                                    .update({
                                  'messages': FieldValue.arrayUnion([
                                    {
                                      'timestamp': DateTime.now(),
                                      'message': _controller.text
                                    }
                                  ])
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection('chats')
                                    .add({
                                  'participants': [googleSignIn.currentUser.id, widget.ownerId],
                                  'messages': [
                                    {
                                      'timestamp': DateTime.now(),
                                      'message': _controller.text
                                    }
                                  ]
                                });
                              }
                            });
                      }
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: "Start conversation"),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: _controller.text.length >= 1 &&
                            _controller.text.isNotEmpty
                        ? () async {
                            if (_controller.text.isNotEmpty &&
                                _controller.text.length >= 1) {
                              await FirebaseFirestore.instance
                                  .collection('insta_chats')
                                  .doc(widget.chatId)
                                  .update({
                                'chats': FieldValue.arrayUnion([
                                  {
                                    'timestamp': DateTime.now(),
                                    'message': _controller.text,
                                    'user': googleSignIn.currentUser.id
                                  }
                                ])
                              });
                              _controller.clear();
                            }
                          }
                        : null,
                    icon: Icon(Icons.send_sharp,
                        color: _controller.text.length > 0 &&
                                _controller.text.isNotEmpty
                            ? Colors.blue
                            : Colors.grey),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
