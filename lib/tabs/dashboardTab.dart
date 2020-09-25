import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_home/classes/provider.dart';
import 'package:go_home/services/approvedServices.dart';
import 'package:go_home/services/serviceChecker.dart';
import 'package:go_home/services/propertyChecker.dart';
import 'package:go_home/views/messages.dart';
import 'package:go_home/views/notifications.dart';
import 'package:go_home/views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../components/searchBar.dart';
import '../components/propertyList.dart';
import '../components/newsLetter.dart';
import '../views/eachProperty.dart';
import '../components/imageButton.dart';
import '../signUp.dart';
import '../views/rentHouses.dart';
import '../views/saleHouses.dart';
import '../views/blogDisplay.dart';
import '../views/topCities.dart';
import '../views/allProperties.dart';
import '../dashboard.dart';

import '../services/services.dart';
import '../services/featuredServices.dart';
import '../classes/property.dart';

import 'dart:async';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../classes/user.dart';

class DashboardTab extends StatefulWidget {
  final User user;

  DashboardTab({this.user});

  @override
  State<StatefulWidget> createState() => _DashboardTabState(user: user);
}

class _DashboardTabState extends State<DashboardTab> {
  int _start = 10;
  int _current = 10;
  bool isAuth = false;

  FlutterLocalNotificationsPlugin notificationsPlugin;

//  void startTimer() {
//    CountdownTimer countDownTimer = new CountdownTimer(
//      new Duration(seconds: _start),
//      new Duration(seconds: 1),
//    );
//
//    var sub = countDownTimer.listen(null);
//    sub.onData((duration) {
//      setState(() {
//        _current = _start - duration.elapsed.inSeconds;
//      });
//    });
//
//    sub.onDone(() {
//   //    print("Done");
//      if (properties.length < 1 && _current < 1) {
//        internetDialog(context);
//      }
//      sub.cancel();
//    });
//  }

  final User user;
  List<Property> properties = List();
  List<Property> filteredProperties = List();

  String typeValue = "Any Property Type";
  String furnValue = "Furnished";
  String regionValue = "Any Region";
  String statusValue = "Any Status";
  String bedroomValue = "Bedrooms";
  String bathroomValue = "Bathrooms";
  String minAmountValue = "Min Amount";
  String maxAmountValue = "Max Amount";

  String number = "5";

  bool isButtonDisabled;
  bool isInitFilter;

  TextEditingController bathroomController = TextEditingController();
  TextEditingController bedroomController = TextEditingController();
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();

  _DashboardTabState({this.user});

  Map data;

  List userData; //Property data

  static List updatedData;

  Future getData() async {
    var response = await http.get(
        Uri.encodeFull("https://www.gohome.ng/api/fetch_featured_api.php"),
        headers: {"Accept": "application/json"});

    userData = json.decode(response.body);

    // setState(() {
    //   updatedData = [for (var i = 0; i <= 2; i += 1) userData[i]];
    // });
  }

  getUserState() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    bool isAuthenticated = shared_User.getBool("isAuth");
    var user = shared_User.getStringList('user');

    setState(() {
      isAuth = isAuthenticated;
    });
  }

  @override
  void initState() {
    super.initState();
    FeaturedServices.getProperties().then((propertiesFromServer) {
      if (mounted) {
        setState(() {
          properties = propertiesFromServer;
          filteredProperties = properties;
        });
      }
    });
//    startTimer();
    getUserState();
//    MessageListener.startChecker();
//    PropertyChecker.startChecker();
    //ApprovedServices.startChecker();
//    startChecker();
//    startPropertyChecker();
  }

  // ---- Notification for messages (start) ---- //
  int _startChecker = 5;
  int _currentChecker = 5;

//  void startChecker() {
//    CountdownTimer countDownTimer = new CountdownTimer(
//      new Duration(seconds: _startChecker),
//      new Duration(seconds: 1),
//    );
//
//    var sub = countDownTimer.listen(null);
//    sub.onData((duration) {
//      // setState(() {
//      _currentChecker = _startChecker - duration.elapsed.inSeconds;
//      // });
//    });
//
//    sub.onDone(() {
//   //    print("Done");
//      if (_currentChecker < 1) {
//        checkForNew();
//        _currentChecker = 5;
//        startChecker();
//      }
//      sub.cancel();
//    });
//  }
//
//  checkForNew() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    String isSame = preferences.getString("isSame");
//    List channelList = preferences.getStringList("channel");
//
//    if (isSame == "false") {
//      // Check if the current logged in user's equals either the sender of the receiver
//      if (channelList[0] == user.id || channelList[0] == user.id) {
//        runNotif();
//        showNotification();
//     //    print(isSame);
//      }
//    } else {
//   //    print(isSame);
//    }
//  }

  Future onSelectNotification(String payload) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Messages(),
      ),
    );
  }

//
//  runNotif() {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//    var iOS = new IOSInitializationSettings();
//    var initSettings = new InitializationSettings(android, iOS);
//    notificationsPlugin.initialize(initSettings,
//        onSelectNotification: onSelectNotification);
//  }
//
//  showNotification() async {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidNotificationDetails(
//        "channelId", "channelName", "channelDescription");
//    var iOS = new IOSNotificationDetails();
//    var platform = new NotificationDetails(android, iOS);
//    await notificationsPlugin.show(
//        0, "New message", "Message from Jane Doe", platform);
//  }

  // ---- Notification for messages (end) ---- //

  // ---- Notification for new properties (start) ---- //

  void startPropertyChecker() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _startChecker),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      // setState(() {
      _currentChecker = _startChecker - duration.elapsed.inSeconds;
      // });
    });

    sub.onDone(() {
      //    print("Done");
      if (_currentChecker < 1) {
        checkForNewProp();
        _currentChecker = 5;
        startPropertyChecker();
      }
      sub.cancel();
    });
  }

  checkForNewProp() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    String isSame = preferences.getString("isPropCount");
//    if (isSame == "false") {
//      propNotif();
//      showPropNotification();
//   //    print(isSame);
//    } else {
//   //    print(isSame);
//    }
  }


  Future onSelectPropNotification(String payload) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notifications(),
      ),
    );
  }

//
//  propNotif() {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//    var iOS = new IOSInitializationSettings();
//    var initSettings = new InitializationSettings(android, iOS);
//    notificationsPlugin.initialize(initSettings,
//        onSelectNotification: onSelectPropNotification);
//  }
//
//  showPropNotification() async {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidNotificationDetails(
//        "channelId", "channelName", "channelDescription");
//    var iOS = new IOSNotificationDetails();
//    var platform = new NotificationDetails(android, iOS);
//    await notificationsPlugin.show(
//        0, "New Property", "New property update", platform);
//  }

  // ---- Notification for new properties (end) ---- //

  // ---- Notification for proprerty Approval -- ///
//   checkForisApproved() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    String isSame = preferences.getString("isApproved");
//    if (isSame == "false") {
//      propNotifApproved();
//      showPropNotificationApproved();
//   //    print(isSame);
//    } else {
//   //    print(isSame);
//    }
//  }
//
//  Future onSelectPropNotificationApproved(String payload) {
//
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => Notifications(),
//      ),
//    );
//  }
//
//  propNotifApproved() {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//    var iOS = new IOSInitializationSettings();
//    var initSettings = new InitializationSettings(android, iOS);
//    notificationsPlugin.initialize(initSettings,
//        onSelectNotification: onSelectPropNotificationApproved);
//  }
//
//  showPropNotificationApproved() async {
//    notificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidNotificationDetails(
//        "channelId", "channelName", "channelDescription");
//    var iOS = new IOSNotificationDetails();
//    var platform = new NotificationDetails(android, iOS);
//    await notificationsPlugin.show(
//        0, "New Property", "New property update", platform);
//  }

  // ------- ////

  @override
  void dispose() {
    super.dispose();
  }

  void filter() {
    List<Property> tempProperty = properties;
    if (regionValue != null &&
        regionValue.trim().isNotEmpty &&
        regionValue != "Any Region") {
      tempProperty = tempProperty
          .where(
              (p) => p.state.toLowerCase().contains(regionValue.toLowerCase()))
          .toList();
    }
    if (typeValue != null &&
        typeValue.trim().isNotEmpty &&
        typeValue != "Any Property Type") {
      tempProperty = tempProperty
          .where(
              (p) => p.propType.toLowerCase().contains(typeValue.toLowerCase()))
          .toList();
    }
    if (statusValue != null &&
        statusValue.trim().isNotEmpty &&
        statusValue != 'Any Status') {
      tempProperty = tempProperty
          .where(
              (p) => p.status.toLowerCase().contains(statusValue.toLowerCase()))
          .toList();
    }
    if (bedroomController.text != null &&
        bedroomController.text.trim().isNotEmpty) {
      tempProperty = tempProperty
          .where((p) => p.bedroom == bedroomController.text)
          .toList();
    }

    if (bathroomController.text != null &&
        bathroomController.text.trim().isNotEmpty) {
      tempProperty = tempProperty
          .where((p) => p.bathroom.contains(bathroomController.text))
          .toList();
    }

    if (minController.text != null && minController.text.trim().isNotEmpty) {
      tempProperty = tempProperty
          .where((p) => int.parse(p.amount) >= int.parse(minController.text))
          .toList();
    }

    if (maxController.text != null && maxController.text.trim().isNotEmpty) {
      tempProperty = tempProperty.where((p) {
        if (int.parse(p.amount) <= int.parse(maxController.text)) {
          print(p.title);
          print("${p.amount} --------- ${maxController.text}");
          print(int.parse(p.amount));
          print(int.parse(maxController.text));
          return true;
        }
        return false;
      }).toList();
    }

    setState(() {
      filteredProperties = tempProperty;
    });
  }

  reload() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Dashboard(
          user: user,
        ),
      ),
    );
  }

  void internetDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        color: Colors.transparent,
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
                      "Having issues viewing properties?",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset(
                      "assets/noInternet.gif",
                      height: 100,
                    ),
                    Text(
                      "Please check your internet connection",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            reload();
                          },
                          icon: Icon(Icons.refresh),
                        ))
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 20,
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
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // CustomAppBar(),
                  GestureDetector(
//                    onTap: showNotification,
                    child: Text("Find Properties around you"),
                  ),
                  SearchBox(),
                  // Text(User.fromJson(user["name"])),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(right: 10),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Flexible(
                              flex: 5,
                              child: ImageButton(
                                label: "Property for \n       rent",
                                imageLink: "assets/rent.png",
                                widget: RentHouses(),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Flexible(
                              flex: 5,
                              child: ImageButton(
                                label: "   View all \n Properties",
                                imageLink: "assets/properties.png",
                                widget: AllProperties(),
                              ),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Flexible(
                              flex: 5,
                              child: ImageButton(
                                label: "Property for \n        sale",
                                imageLink: "assets/sale.png",
                                widget: SaleHouses(),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            !isAuth
                                ? Flexible(
                                    flex: 5,
                                    child: ImageButton(
                                        label: "Become an \n    agent",
                                        imageLink: "assets/cus_sup.png",
                                        widget: SignUp()),
                                  )
                                : Flexible(
                                    flex: 5,
                                    child: ImageButton(
                                        label: "Go to \n profile",
                                        imageLink: "assets/person.png",
                                        widget: Profile()),
                                  )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Flexible(
                              flex: 5,
                              child: ImageButton(
                                  label: "Top cities \n   ",
                                  imageLink: "assets/building.png",
                                  widget: TopCities()),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Flexible(
                              flex: 5,
                              child: ImageButton(
                                label: "Blog Posts \n    ",
                                imageLink: "assets/blog.png",
                                widget: BlogDisplay(),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: NewsLetter(),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Colors.red,
                            ),
                            Text("Top featured properties"),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.topRight,
                          child: MaterialButton(
                              disabledColor: Colors.grey,
                              color: Colors.white,
                              elevation: 0,
                              key: GlobalKey(debugLabel: "sca"),
                              onPressed: () {
                                setState(() {
                                  _settingModalBottomSheet(context);
                                });
                                //    print(filteredProperties);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.filter_list),
                                  Text(
                                    "Filter",
                                    style: TextStyle(
                                      color: Color(0xFF79c942),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      )
                    ],
                  ),

                  filteredProperties.length < 1 && _current > 0
                      ? Container(
                          height: 100,
                          width: double.infinity,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white,
                            child: Container(
                              width: double.infinity,
                              child: Row(
                                children: <Widget>[Card()],
                              ),
                            ),
                          ),
                        )
                      : filteredProperties.length < 1 && _current == 0
                          ? Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Icon(Icons.error,
                                      size: 70, color: Colors.red),
                                  Container(
                                    padding: EdgeInsets.all(30),
                                    child: Center(
                                      child: Text(
                                        "Could not fetch data from server. This is possibly due to the absence of internet connection",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: filteredProperties.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = filteredProperties[index];
                                return PropertyList(
                                  amount: filteredProperties[index].amount,
                                  imagePath: filteredProperties[index].img1,
                                  location: filteredProperties[index].address,
                                  propId: filteredProperties[index].prop_id,
                                  region: filteredProperties[index].region,
                                  saleOrRent: filteredProperties[index].status,
                                  title: filteredProperties[index].title,
                                  phone: filteredProperties[index].phone,
                                  state: filteredProperties[index].state,
                                  name: filteredProperties[index].name,
                                  email: filteredProperties[index].user_email,
                                  isFav: filteredProperties[index].isFav,
                                  item: item,
                                  goto: EachProperty(
                                    item: item,
                                  ),
                                );
                              },
                            )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 500,
            padding: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModelState) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: ListView(
                    children: <Widget>[
                      Text(
                        "Filter Property type",
                        style: TextStyle(fontSize: 30),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black45,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.all(5),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: regionValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 0,
                            color: Colors.black,
                          ),
                          onChanged: (String newValue) {
                            setModelState(() {
                              regionValue = newValue;
                            });
                          },
                          items: <String>[
                            'Any Region',
                            'Abia',
                            'Abuja',
                            'Adamawa',
                            'Akwa Ibom',
                            'Anambra',
                            'Bauchi',
                            'Bayelsa',
                            'Benue',
                            'Borno',
                            'Cross River',
                            'Delta',
                            'Ebonyi',
                            'Enugu',
                            'Edo',
                            'Ekiti',
                            'Gombe',
                            'Imo',
                            'Jigawa',
                            'Kaduna',
                            'Kano',
                            'Katsina',
                            'Kebbi',
                            'Kogi',
                            'Kwara',
                            'Lagos',
                            'Nasarawa',
                            'Niger',
                            'Ogun',
                            'Ondo',
                            'Osun',
                            'Oyo',
                            'Plateau',
                            'Rivers',
                            'Sokoto',
                            'Taraba',
                            'Yobe',
                            'Zamfara'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black45,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.all(5),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: typeValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 0,
                            color: Colors.black,
                          ),
                          onChanged: (String newValue) {
                            setModelState(() {
                              typeValue = newValue;
                            });
                          },
                          items: <String>[
                            'Any Property Type',
                            'House',
                            'Offic'
                                'e',
                            'Store',
                            'Land'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black45,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.all(5),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: statusValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 0,
                            color: Colors.black,
                          ),
                          onChanged: (String newValue) {
                            setModelState(() {
                              statusValue = newValue;
                            });
                          },
                          items: <String>['Any Status', 'Sale', 'Rent']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black45,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: bedroomController,
                            decoration: InputDecoration(hintText: "Bedrooms"),
                          )),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: bathroomController,
                          decoration: InputDecoration(hintText: "Bathroom"),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black45,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: minController,
                          decoration: InputDecoration(hintText: "Min Amount"),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black45,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: maxController,
                          decoration: InputDecoration(hintText: "Max Amount"),
                        ),
                      ),
                      MaterialButton(
                        height: 50,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        onPressed: () {
                          // setState(() {
                          //   filteredProperties = properties
                          //       .where((p) => p.amount.contains("5"))
                          //       .toList();
                          // });
                          setModelState(() {
                            isButtonDisabled = false;
                            number = "3";
                          });
                          Navigator.pop(context);
                          filter();
                        },
                        child: Text(
                          "Apply Filter",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF79c942),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}
