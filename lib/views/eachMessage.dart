import 'package:flutter/material.dart';
import 'package:go_home/classes/message.dart';
import 'package:go_home/classes/provider.dart';
import 'package:go_home/components/InspectionView.dart';
import 'package:flutter/material.dart';
import 'package:go_home/components/messagePill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network/network.dart' as network;

import 'package:http/http.dart';
import 'package:quiver/async.dart';
import 'dart:async';
import 'dart:io';
import '../classes/success.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class EachMessage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String propId;
  final String img1;
  final dynamic item;

  EachMessage({this.senderId, this.receiverId, this.propId, this.img1, this.item});

  @override
  State<StatefulWidget> createState() => _EachMessageState(
      senderId: senderId, receiverId: receiverId, propId: propId, img1:img1,
      item:item);
}

class _EachMessageState extends State<EachMessage> {
  final String senderId;
  final String receiverId;
  final String propId;
  final String img1;
  final dynamic item;

  _EachMessageState({this.senderId, this.receiverId, this.propId, this.img1, this.item});

  Map data;
  List userData;
  static List updatedData;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  // final String dataKind;

  bool isAuth = false;

  TextEditingController messageController = TextEditingController();

  int _start = 10;
  int _current = 10;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      if(mounted) {
        setState(() {
          _current = _start - duration.elapsed.inSeconds;
        });
      }
    });

    sub.onDone(() {
   //    print("Done");
      sub.cancel();
    });
  }

   ScrollController _scrollController = new ScrollController();
  final MainProvider mainProvider = new MainProvider();

  getMessage() async {
    return this._memoizer.runOnce(() async {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      shared_User.setString("last-${item['id']}", DateTime.now().toString());
      bool isAuthenticated = shared_User.getBool("isAuth");
      List user = shared_User.getStringList("user");
      setState(() {
        isAuth = isAuthenticated;
        item['read'] = true;
      });
      var response;

      if (isAuthenticated) {
        //print("----------------------------------------");
//        print(
//            "http://www.gohome.ng/api/get_single_message.php?receiver_id=${user[0]}&prop_id=$propId");
        response = await this.mainProvider.dio.get("http://www.gohome"
            ".ng/api/get_single_message.php", queryParameters: {
          "receiver_id":user[0],
          "prop_id":propId,
          "sender_id": senderId
        });
        List userData;
//         print(
//            "http://www.gohome.ng/api/get_single_message.php?receiver_id=${user[0]}&prop_id=$propId");
        userData = response.data;
//        print(response.data);
//         Message messages =Message.fromJson(response.body);

//         userData = [messages.title, messages.body, messages.senderName];

        if (userData.isEmpty) {
          return null;
        } else {
           setState(() {
             updatedData = [for (var i = 0; i < 1; i += 1) userData[i]];
           });

           userData.forEach((f){
             print(f);
           });

          return userData;
        }

      } else {
     //    print("Not auth");
        return null;
      }
    });
  }

 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    getUser();
  }

  String userNo;

  getUser() async{
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var user = shared_User.getStringList('user');

    setState(() {
      userNo = user[0]; 
    });
  }

  sendMessage() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var user = shared_User.getStringList('user');


    String receiverId = user[0].toString();

 //    print("User some: $receiverId");

    String body;

    String title = "Sending Message";
    String message = messageController.text;

    if (title.length > 0 && message.length > 0) {
      // setState(() {
      //   isLoading = true;
      // });

      // set up POST request arguments
      String url = 'https://www.gohome.ng/send_message.php';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json =
          '{"sender_id" : "${senderId}", "receiver_id" : "${receiverId}", "title" : "${title}", "message" : "${message}", "propId" : "${propId}", "sender" : ${receiverId} }';
      // make POST request
      Response response = await post(url, headers: headers, body: json);
      // check the status code for the result
      int statusCode = response.statusCode;
      // this API passes back the id of the new item added to the body
      body = response.body;

      Success success = Success.fromJson(jsonDecode(body));
      if (success.status == "OK") {
        Map decode_options = jsonDecode(body);
        // String userData = user.email;
        // shared_Success.setString('user', userData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EachMessage(
              senderId: senderId,
              propId: propId,
              img1: img1,
              item:item
            ),
          ),
        );
        // setState(() {
        //   isLoading = false;
        // });
      }
    } else {
   //    print("error");
    }
  }

  


  @override
  Widget build(BuildContext context) {
    if(_scrollController.hasClients) {
      Timer(Duration(milliseconds: 1000), () =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Container(
                child: FadeInImage.assetNetwork(
                  image : "http://gohome.ng/assets/upload/" +
                      propId +
                      "/" +
                      img1,
                  width: double.infinity,
                  placeholder: "assets/property_location.jpg",
                ),
              ),
            ),
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: new FutureBuilder(
                  future: getMessage(),
                  builder: (context, snapshot) {
                    //print(snapshot);
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
                      var myData = snapshot.data;
                      //  _scrollController.animateTo(
                      //     0.0,
                      //     curve: Curves.easeOut,
                      //     duration: const Duration(milliseconds: 300)
                      //   );
                      return ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = myData[index];
                          if (item["sender"] == userNo) {
                            return Wrap(
                              alignment: WrapAlignment.end,
                              children: <Widget>[
                                MessagePill(
                                  msgData: item["message"],
                                  identity: "You",
                                  timestamp: item["created_at"],
                                )
                              ],
                            );
                          } else {
                            return Wrap(
                              alignment: WrapAlignment.start,
                              children: <Widget>[
                                MessagePill(
                                  msgData: item["message"],
                                  identity: "",
                                  timestamp: item["created_at"],
                                )
                              ],
                            );
                          }
                        },
                        itemCount: myData.length,
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
                color: Colors.grey,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            hintText: "Type your message here"
                          ),
                          controller: messageController,
                        ),
                        )
                      ),
                    ),
                    MaterialButton(
                      onPressed: sendMessage,
                      textColor: Colors.white,
                      child: Text("SEND"),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
