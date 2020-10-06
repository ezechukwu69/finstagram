import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static String id = "/signUpPage";
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  TabController _tbController;
  TextEditingController ctrl1 = TextEditingController();
  TextEditingController ctrl2 = TextEditingController();
  EdgeInsetsGeometry pad = const EdgeInsets.symmetric(horizontal: 20.0);
  bool show = false;
  bool show2 = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tbController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    Widget spacer() {
      return SizedBox(
        height: 14.0,
      );
    }

    return WillPopScope(
      onWillPop: () {
        bool data = false;
        return showDialog(
            context: context,
            child: Center(
                child: FractionallySizedBox(
                  heightFactor: 0.37,
                  widthFactor: 0.7,
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Text("Discard info? ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text("If you go back now, any information you've entered so far will be discarded",style: TextStyle(color: Colors.grey,fontSize: 15),textAlign: TextAlign.center,),
                        ),
                        Spacer(),
                        Divider(thickness: 1,),
                        SizedBox(
                          height: 30.0,
                            child: FlatButton(child: Text("Discard",style: TextStyle(color: Colors.blue,fontSize: 18)), onPressed: (){ Navigator.pop(context, true);},)),
                        Divider(thickness: 1,),
                        SizedBox(
                          height: 30.0,
                          child: FlatButton(child: Text("Cancel",style: TextStyle(color: Colors.black87,fontSize: 18),), onPressed: (){
                            Navigator.of(context, rootNavigator: true).pop(false);
                          }),
                        ),
                        SizedBox(height: 7,)
                      ],
              ),
            ),
                )));
      },
      child: Scaffold(
        body: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Icon(CupertinoIcons.person_solid, size: 200)),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: pad,
                child: TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    controller: _tbController,
                    onTap: (value) => setState(() => index = value),
                    tabs: [Tab(text: "PHONE"), Tab(text: "EMAIL")]),
              ),
              IndexedStack(
                index: index,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      spacer(),
                      Container(
                        height: 50.0,
                        child: Padding(
                          padding: pad,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                if (ctrl1.text.isNotEmpty &&
                                    ctrl1.text.trim().length > 0 &&
                                    !value.trim().contains(' ')) {
                                  show = true;
                                } else {
                                  show = false;
                                }
                              });
                            },
                            controller: ctrl1,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.add_location),
                                suffixIcon: IconButton(
                                    icon: Icon(CupertinoIcons.clear_thick),
                                    onPressed: () => setState(() {
                                          ctrl1.text = "";
                                          show = false;
                                        })),
                                labelText: "Phone",
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ),
                      spacer(),
                      Padding(
                        padding: pad,
                        child: Text(
                            "You may recieve SMS updates from instagram and can opt out at any time."),
                      ),
                      spacer(),
                      Container(
                          width: MediaQuery.of(context).size.width / 0.25,
                          child: Padding(
                              padding: pad,
                              child: MaterialButton(
                                  disabledColor: Colors.blue[200],
                                  onPressed: show ? () {} : null,
                                  height: 50.0,
                                  child: Text("Next",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                  color: Colors.blueAccent[700]))),
                      spacer(),
                      spacer(),
                      spacer(),
                      spacer()
                    ],
                  ),
                  Column(
                    children: [
                      spacer(),
                      Container(
                        height: 50.0,
                        child: Padding(
                          padding: pad,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                if (ctrl2.text.isNotEmpty &&
                                    ctrl2.text.trim().length > 0 &&
                                    ctrl2.text.contains('@') &&
                                    !value.trim().contains(' ')) {
                                  show2 = true;
                                } else {
                                  show2 = false;
                                }
                              });
                            },
                            controller: ctrl2,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(CupertinoIcons.clear_thick),
                                    onPressed: () => setState(() {
                                          ctrl2.text = "";
                                          show2 = false;
                                        })),
                                labelText: "Email",
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ),
                      spacer(),
                      Container(
                          width: MediaQuery.of(context).size.width / 0.25,
                          child: Padding(
                              padding: pad,
                              child: MaterialButton(
                                  disabledColor: Colors.blue[200],
                                  onPressed: show2 ? () {} : null,
                                  height: 50.0,
                                  child: Text("Next",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                  color: Colors.blueAccent[700]))),
                    ],
                  )
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.5))),
                  height: 50.0,
                  child: Center(
                    child: RichText(
                        text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey[600]),
                            children: [
                          TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                  color: Colors.deepPurple[900],
                                  fontWeight: FontWeight.bold))
                        ])),
                  )),
            ),
          )
        ]),
      ),
    );
  }
}
