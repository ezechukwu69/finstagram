import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Fluttergram/pages/signup.dart';

class SignInPage extends StatefulWidget {
  static String id = "/";
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool show = false;
  bool visible;
  bool loading = false;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  TextEditingController ctrl1 = TextEditingController();
  TextEditingController ctrl2 = TextEditingController();
  @override
  void initState() {
    visible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 0.25;
    EdgeInsetsGeometry paddingWidth =
    const EdgeInsets.symmetric(horizontal: 30.0);
    Widget space() {
      return SizedBox(
        height: 15.0,
      );
    }

    return Scaffold(
      body: Stack(children: [
        GestureDetector(
          onTap: () {
            setState(() {
              focusNode1.unfocus();
              focusNode2.unfocus();
            });
          },
          child: Center(
            widthFactor: 1,
            child: Card(
              elevation: 0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Instagram',
                        style: GoogleFonts.norican().copyWith(fontSize: 50),
                        textAlign: TextAlign.center),
                    space(),
                    Container(
                      height: 50.0,
                      child: Padding(
                        padding: paddingWidth,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              if (ctrl1.text.isNotEmpty &&
                                  ctrl2.text.isNotEmpty &&
                                  ctrl1.text.trim().length > 0 &&
                                  ctrl2.text.trim().length > 0 &&
                                  !value.trim().contains(' ') &&
                                  ctrl2.text != ' ') {
                                show = true;
                              } else {
                                show = false;
                              }
                            });
                          },
                          controller: ctrl1,
                          focusNode: focusNode1,
                          decoration: InputDecoration(
                              labelText: "email", border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                    space(),
                    Container(
                      height: 50.0,
                      child: Padding(
                        padding: paddingWidth,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              if (ctrl1.text.isNotEmpty &&
                                  ctrl2.text.isNotEmpty &&
                                  ctrl1.text != '' &&
                                  !value.trim().contains(' ') &&
                                  ctrl1.text.trim().length > 0 &&
                                  ctrl2.text.trim().length > 0 &&
                                  ctrl2.text != '') {
                                show = true;
                              } else {
                                show = false;
                              }
                            });
                          },
                          controller: ctrl2,
                          focusNode: focusNode2,
                          obscuringCharacter: '*',
                          obscureText: visible,
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                color: visible ? Colors.grey : Colors.blue,
                                icon: Icon(CupertinoIcons.eye),
                                onPressed: () {
                                  if (visible == false) {
                                    setState(() {
                                      visible = true;
                                    });
                                  } else {
                                    setState(() {
                                      visible = false;
                                    });
                                  }
                                },
                              )),
                        ),
                      ),
                    ),
                    space(),
                    Container(
                      width: width,
                      child: Padding(
                        padding: paddingWidth,
                        child: MaterialButton(
                            height: 50.0,
                            disabledColor: Colors.blue[100],
                            color: Colors.blue,
                            onPressed: show
                                ? () {
                              setState(() {
                                loading = true;
                              });
                            }
                                : null,
                            child: !loading
                                ? Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            )
                                : Container(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )),
                      ),
                    ),
                    space(),
                    GestureDetector(
                      onTap: () {},
                      child: RichText(
                          text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                        color: Colors.deepPurple[900],
                                        fontWeight: FontWeight.bold))
                              ])),
                    ),
                    space(),
                    Padding(
                      padding: paddingWidth,
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              flex: 1,
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                              ))
                        ],
                      ),
                    ),
                    space(),
                    Container(
                      width: width,
                      child: Padding(
                        padding: paddingWidth,
                        child: InkWell(
                          onTap: () {
                            setState(() {});
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0)),
                              height: 50.0,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 30.0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          child: FlutterLogo(),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Sign in with facebook',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ])),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(SignUpPage.id),
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5))),
                height: 50.0,
                child: Center(
                  child: RichText(
                      text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                    color: Colors.deepPurple[900],
                                    fontWeight: FontWeight.bold))
                          ])),
                )),
          ),
        )
      ]),
    );
  }
}