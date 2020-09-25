import 'package:flutter/material.dart';
import 'package:go_home/views/testPicker.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import './tabs/dashboardTab.dart';
import './tabs/favoritesTab.dart';
import './tabs/notifTab.dart';
import './tabs/blogTab.dart';
import './views/profile.dart';
import './classes/user.dart';
import './views/allProperties.dart';
import './views/inquiryForm.dart';
import './Login.dart';
import './views/addProperties.dart';
import './views/messages.dart';

class Dashboard extends StatefulWidget {
  final User user;

  Dashboard({this.user});

  @override
  _DashboardState createState() => _DashboardState(user: user);
}

class _DashboardState extends State<Dashboard> {
  final User user;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;

  bool isAuth = false;

  void _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
   //    print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}";
      });
    } catch (e) {
   //    print(e);
    }
  }

  getUserLocation() async{
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    String location = _currentAddress;
    shared_User.setString("geoLocation", location);
  }

  getUserState() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    bool isAuthenticated = shared_User.getBool("isAuth");
    var user = shared_User.getStringList('user');

    setState(() {
      isAuth = isAuthenticated;
    });

    // String senderId = user[0].toString();

    // if (senderId.length > 0) {
    //   return true;
    // }
    // return false;
  }



  _makeAuth() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var _user = shared_User.getStringList('user');

    var id = _user[0];
    String body;

    // set up POST request arguments
    String url = 'https://www.gohome.ng/_auth_user.php';
    Map<String, String> headers = {"Content-type": "application/json"};
    var s = '{"id": ' +
        " \"" +
        id +
        "\"" +
        ' }';
    String json = s;
    // make POST request
    http.Response response = await http.post(url, headers: headers, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    body = response.body;

    User user = User.fromJson(jsonDecode(body));
    print("HEere");
    if (user.status == "OK") {
      shared_User.setBool("isAuth", true);

      Map decode_options = jsonDecode(body);
      // String userData = user.email;
      shared_User.setStringList('user', [
        user.id,
        user.email,
        user.avatar,
        user.name,
        user.message,
        user.password,
        user.phone,
        user.status,
        user.website
      ]);
    }
  }



  @override
  void initState() {
    super.initState();
    _makeAuth();
    getUserState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _DashboardState({this.user});

  int _currentIndex = 0;

  final tabs = [DashboardTab(), FavoritesTab(), Messages(dashbaord: true), 
    BlogTab()];

  bool boolTrue = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          child: Column(
        children: <Widget>[
          Container(
            height: 300,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/bul2.jpg"),
              fit: BoxFit.cover,
            )),
          ),
          Container(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllProperties(),
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black45,
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text(
                      "Properties",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      // MaterialPageRoute(builder: (context) => InquiryForm()),
                      MaterialPageRoute(builder: (context) => InquiryForm()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text(
                      "Inquiry Form",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                isAuth ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProperties(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black45,
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text(
                      "Add Property",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
                : Container(),
                !isAuth
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black45,
                      ),
                    ),
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          child: Text(
                            "Sign in",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    : Text("")
              ],
            ),
          ),
        ],
      )),
      // appBar:  AppBar(...) : null
      appBar: boolTrue
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Image(
                image: AssetImage('assets/gohome.png'),
                width: 100,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Color(0xFF79c942),
                  ),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                ),
                isAuth
                    ? Container(
                        margin: EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFF79c942),
                          child: IconButton(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profile(),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Text("")
              ],
            )
          : null,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF79c942),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text("Favorites"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text("Messages"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text("Blog"),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
