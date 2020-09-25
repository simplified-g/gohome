// import 'package:flutter/material.dart';

import 'package:go_home/views/eachMessage.dart';

import '../components/InspectionView.dart';
// import 'messaging.dart';

// class Messages extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _MessagesState();

// }

//  class _MessagesState extends State<Messages>{
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Messages"),
//         backgroundColor: Color(0xFF79c942),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Container(
//             alignment: Alignment.center,
//             padding: EdgeInsets.all(10),
//             child: Text("You have 3 new messages."),
//           ),

//           InspectionView(
//             amount: "1000",
//             id: "1",
//             location: "Lagos",
//             propId: "123",
//             requestQuestion: "Request to inspect house",
//             saleOrRent: "null",
//             state: "Lagos",
//             title: "John Doe",
//             followUp: "When sholud I come?",
//           ),
//           InspectionView(
//             amount: "1000",
//             id: "1",
//             location: "Lagos",
//             propId: "123",
//             requestQuestion: "Request to inspect house",
//             saleOrRent: "null",
//             state: "Lagos",
//             title: "Jane Doe",
//             followUp: "I would love a rose garden.",
//           ),
//           InspectionView(
//             amount: "1000",
//             id: "1",
//             location: "Lagos",
//             propId: "123",
//             requestQuestion: "Request to inspect house",
//             saleOrRent: "null",
//             state: "Lagos",
//             title: "John Dee",
//             followUp: "I would be free by 2pm.",
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xFF79c942),
//         child: Icon(Icons.add),
//         onPressed: (){
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Messaging()
//             ));
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quiver/async.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';

import '../views/eachProperty.dart';
import '../components/propertyList.dart';
import '../components/pills.dart';
import '../login.dart';
import '../classes/message.dart';
import '../components/notificationPill.dart';

class Messages extends StatefulWidget {
  final String dataKind;
  final bool dashbaord;

  Messages({this.dataKind, this.dashbaord = false});

  @override
  State<StatefulWidget> createState() => _MessagesState(dataKind: dataKind);
}

class _MessagesState extends State<Messages> {
  Map data;
  List userData;
  String me;
  static List updatedData;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  final String dataKind;

  bool isAuth = false;

  _MessagesState({this.dataKind});

  Future isAuthValid() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    bool isAuthenticated = shared_User.getBool("isAuth");
    setState(() {
      isAuth = isAuthenticated;
    });
  }

  getData() async {
    return this._memoizer.runOnce(() async {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      bool isAuthenticated = shared_User.getBool("isAuth");
      List user = shared_User.getStringList("user");
      setState(() {
        isAuth = isAuthenticated;
      });
      var response;

      if (isAuthenticated) {
        setState(() {
          me = user[0];
        });
        response = await http.get(
            Uri.encodeFull(
                "http://www.gohome.ng/get_message.php?receiver_id=${user[0]}&sender_no=${user[0]}"),
            headers: {"Accept": "application/json"});
        List userData;
        userData = json.decode(response.body);

        // Message messages =Message.fromJson(response.body);

        // userData = [messages.title, messages.body, messages.senderName];

        if (userData.isEmpty) {
          return null;
        } else {
          setState(() {
            updatedData = [for (var i = 0; i < 1; i += 1) userData[i]];
          });

          return userData;
        }
      } else {
        return null;
      }
    });
  }

  int _start = 10;
  int _current = 10;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      if (mounted) {
        setState(() {
          _current = _start - duration.elapsed.inSeconds;
        });
      }
    });

    sub.onDone(() {
      sub.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    isAuthValid();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.dashbaord
          ? null
          : AppBar(
              title: Text("My Messages"),
              backgroundColor: Color(0xFF79c942),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: Row(
                  children: <Widget>[
                    Text(
                      "Showing all Messages for this user",
                      style: TextStyle(fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            isAuth
                ? Container(
                    margin: EdgeInsets.only(top: 20),
                    child: new FutureBuilder(
                      future: getData(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData && _current > 0) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData && _current == 0) {
                          return Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 250),
                                child: Icon(
                                  Icons.priority_high,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                              Container(
                                child: Text(
                                  "You don't have any messages!!!",
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            ],
                          );
                        } else {
                          List myData = snapshot.data;
                          return ListView(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            children: myData.map((item) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EachMessage(
                                              senderId: item["sender_id"],
                                              propId: item["propId"],
                                              img1: item["img1"],
                                            item: item
                                            )),
                                  );
                                },
                                child: InspectionView(
                                  id: item["id"],
                                  title: me == item["receiver_id"] ?
                                    item["sender_name"] : item["receiver_name"],
                                  requestQuestion: item["title"],
                                  followUp: item["message"],
                                  item: item
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 200),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "You are not logged in!!!",
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          child: MaterialButton(
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Color(0xFF79c942),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
