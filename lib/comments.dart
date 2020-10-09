import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  CommentsPage({Key key, this.postId}) : super(key: key);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
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
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Comments',
          style: TextStyle(color: Colors.black),
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
                        .collection("comments")
                        .doc(widget.postId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data['comments'].length > 0) {
                          List<dynamic> data = snapshot.data['comments'];
                          data.sort((a, b) =>
                              b['timestamp'].compareTo(a['timestamp']));
                          data.reversed;
                          return ListView(
                            reverse: true,
                            children: data.map((e) {
                              if (e['user'] == googleSignIn.currentUser.id) {
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 12.0,
                                                          top: 8.0),
                                                  child: Text(
                                                    'Me',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                e['comment'],
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
                                            FutureBuilder(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('insta_users')
                                                    .doc(e['user'])
                                                    .get(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 12.0,
                                                                  top: 8.0),
                                                          child: Text(
                                                            snapshot.data['username'],
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  return Container();
                                                }),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                e['comment'],
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
                              }
                            }).toList(),
                          );
                        } else {
                          return Center(
                            child: Text("No comments"),
                          );
                        }
                      }
                      return Center(
                        child: Text("No comments"),
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
                            .collection('comments')
                            .doc("${widget.postId}")
                            .update({
                          'comments': FieldValue.arrayUnion([
                            {
                              "timestamp": DateTime.now(),
                              "comment": _controller.text
                            }
                          ])
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
                        labelText: "Enter your comment"),
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
                                  .collection('comments')
                                  .doc("${widget.postId}")
                                  .update({
                                'comments': FieldValue.arrayUnion([
                                  {
                                    "timestamp": DateTime.now(),
                                    "comment": _controller.text,
                                    "user": googleSignIn.currentUser.id
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
