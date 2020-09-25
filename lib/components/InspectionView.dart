import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_home/classes/provider.dart';

import 'package:quiver/async.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import './pills.dart';

class InspectionView extends StatefulWidget {
  final String id;
  final String amount;
  final String location;
  final String propId;
  final String state;
  final String requestQuestion;
  final String imagePath;
  final String saleOrRent;
  final String title;
  final String followUp;
  final dynamic item;

  InspectionView({
    this.id,
    this.amount,
    this.location,
    this.propId,
    this.requestQuestion,
    this.state,
    this.imagePath,
    this.saleOrRent,
    this.title,
    this.followUp,
    this.item,
  });

  @override
  _InspectionViewState createState() => _InspectionViewState(
      this.id,
      this.amount,
      this.location,
      this.propId,
      this.state,
      this.requestQuestion,
      this.imagePath,
      this.saleOrRent,
      this.title,
      this.followUp,
      this.item);
}

class _InspectionViewState extends State<InspectionView> {
  final String id;
  final String amount;
  final String location;
  final String propId;
  final String state;
  final String requestQuestion;
  final String imagePath;
  final String saleOrRent;
  final String title;
  final String followUp;
  final dynamic item;

  _InspectionViewState(
      this.id,
      this.amount,
      this.location,
      this.propId,
      this.state,
      this.requestQuestion,
      this.imagePath,
      this.saleOrRent,
      this.title,
      this.followUp,
      this.item);

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  final MainProvider mainProvider = new MainProvider();
  int unread = 0;


  @override
  void initState() {
    super.initState();
    this.getMessage();
  }

  getMessage() async {
    return this._memoizer.runOnce(() async {
      SharedPreferences shared_User = await SharedPreferences.getInstance();
      String lastMessage = shared_User.getString("last-${this.id}");
      bool isAuthenticated = shared_User.getBool("isAuth");
      List user = shared_User.getStringList("user");
      Response response;

      if (isAuthenticated) {
        //print("----------------------------------------");
//        print(
//            "http://www.gohome.ng/api/get_single_message.php?receiver_id=${user[0]}&prop_id=$propId");
        response = await this.mainProvider.dio.get(
            "http://www.gohome"
            ".ng/api/get_single_message.php",
            queryParameters: {
              "receiver_id": user[0],
              "prop_id": item['propId'],
              "sender_id": item['sender_id']
            });
        List userData;
        userData = response.data;

        if (userData.isEmpty) {
          return null;
        } else {
          if(item['read'] == null) {
            int _unread = 0;
            userData.forEach((f) {
              if (lastMessage == null || lastMessage == '' || DateTime
                  .parse
                (f['created_at'])
                  .millisecondsSinceEpoch >
                  DateTime
                      .parse(lastMessage)
                      .millisecondsSinceEpoch) {
                _unread ++;
              }
            });

            setState(() {
              unread = _unread;
            });
          }
          return userData;
        }
      } else {
        //    print("Not auth");
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 95,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage(
                    "assets/cus_sup.png",
                  ),
                  backgroundColor: Colors.white30,
                  foregroundColor: Colors.white38,
                  maxRadius: 30,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          title.length > 20
                              ? title.substring(0, 17) + "..."
                              : title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF79c942),
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Pill("Request"),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(requestQuestion),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text(followUp),
                            unread > 0 ?
                            Pill("${unread.toString()}")
                            : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
