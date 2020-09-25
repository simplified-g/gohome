import 'package:flutter/material.dart';
import 'package:go_home/classes/provider.dart';
import 'package:dio/dio.dart';
import 'package:quiver/async.dart';
import 'dart:async';
import 'dart:convert';

import '../components/labelledInput.dart';
import '../classes/success.dart';

class NewsLetter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewsLetterState();
}


class _NewsLetterState extends State<NewsLetter> {
  TextEditingController subController =TextEditingController();

  _subscribe() async {
    String username = "";
    String email = subController.text;
    String message = "Subscription";

  

    String body;

    String url = "https://us19.api.mailchimp.com/3.0/lists/c5ec055288/members/";
    var data = {
      "email_address": email,
      "status": "subscribed",
    };
    this._mainProvider.dio.options.headers = {
      "Authorization": "apikey cbf77dd68fb545dd6228c5edcd26b9a4-us19",
      "Content-Type": "application/json"
    };
    try {
      Response resp = await this._mainProvider.dio.post(url, data: data);
      showSimpleCustomDialog(context, "Success", "Subscription successful");
      subController.clear();
    } on DioError catch (e) {
      showSimpleCustomDialog(context, "Error", "Message not sent");
      print(e.message);
    }
 //    print(body);

//    Success success = Success.fromJson(jsonDecode(body));
//    if (success.status == "OK") {
//
//      Map decode_options = jsonDecode(body);
//      // String userData = user.email;
//      // shared_Success.setString('user', userData);
//      // Navigator.push(
//      //   context,
//      //   MaterialPageRoute(
//      //     builder: (context) => Dashboard(),
//      //   ),
//      // );
//       showSimpleCustomDialog(context, "Success", "Subscription successful");
//
//
//       subController.text = "";
//
//    } else {
//      showSimpleCustomDialog(context, "Error", "Message not sent");
//   //    print('error connecting' + success.status);
//    }
  }


  final MainProvider _mainProvider = new MainProvider();

  void showSimpleCustomDialog(BuildContext context, String messageHead, String messageBody) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      messageHead,
                      style: TextStyle(fontSize: 20),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        messageBody,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF79c942), fontSize: 20),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Center(
                    child: MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok!',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: EdgeInsets.fromLTRB(10, 2, 5, 2),
              child: TextField(
                controller: subController,
                decoration: InputDecoration(
                  hintText: "Subscribe to our newsletter",
                  border: InputBorder.none
                ),
              )
            ),
            GestureDetector(
              onTap: (){
                _subscribe();
              },
              child: Card(
              elevation: 0,
              margin: EdgeInsets.only(right: 0, top: 0, bottom: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              color: Color(0xFF79c942),
              child: Container(
                padding: EdgeInsets.all(2),
                child: IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            )
          ],
        ),
      ),
    )
    );
  }
}
