import 'package:flutter/material.dart';
import 'package:go_home/views/profile.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_home/classes/success.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../classes/user.dart';
import '../components/labelledInput.dart';
import 'eachProperty.dart';

class ModifyProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModifyProfileState();
}

class _ModifyProfileState extends State<ModifyProfile> {
  Future<File> file;

  Dialog simpleDialog;

  List user;
  String user_id, user_email;

  int _start = 10;
  int _current = 10;

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  // getUserDetails() async {
  //   SharedPreferences shared_User = await SharedPreferences.getInstance();
  //   // Map userMap = jsonDecode(shared_User.getString('user'));
  //   user = shared_User.getStringList('user');
  //   debugPrint(user.toString());
  //   debugPrint(user[2]);

  //   setState(() {
  //     user_id = user[0];
  //     user_email = user[1];
  //     print(user_email);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  static final String uploadEndPoint =
      'https://gohome.ng/uploadProperty_image_api.php';
  String status = '';

  String base64String;
  File tmpFile;

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String oldPassword;
  TextEditingController passController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  bool pass = true;
  bool newPass = true;
  bool confirmPass = true;

  TextEditingController phoneController = TextEditingController();
  TextEditingController webController = TextEditingController();

  String myString, userId;

  getUserDetails() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    // Map userMap = jsonDecode(shared_User.getString('user'));
    user = shared_User.getStringList('user');
    print(user);
    debugPrint(user.toString());
    debugPrint(user[2]);

    setState(() {
      myString = user[3];
      userController.text = user[3];
      emailController.text = user[1];
      phoneController.text = user[6];
      webController.text = user[8];
      oldPassword = user[5];
      userId = user[0];
    });
  }

  _updateUserProfile(String filename) async {
    String username = userController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String website = webController.text;
//    String password = passController.text;
    SharedPreferences shared_User = await SharedPreferences.getInstance();

    String body;

    // if (email.length > 0) {
    setState(() {
//       isLoading = true;
    });

    // set up POST request arguments
    String url = 'https://www.gohome.ng/_update_user_api.php';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json =
        '{"name" : "${username}", "website" : "${website}", "email" : "${email}", "phone" : "${phone}", "user_id" : "${userId}", "img_name" : "${filename}" }';
    // make POST request

    print(json);
    Response response = await post(url, headers: headers, body: json);
    // Response response = await post(url, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    body = response.body;

    print(body.toString());

    Success success = Success.fromJson(jsonDecode(body));
    if (success.status == "OK") {
      debugPrint(success.message);
      Map decode_options = jsonDecode(body);
      User user = User.fromJson(jsonDecode(body));
      String uploadUrl = "https://www.gohome.ng/upload_image_api.php";

      Navigator.of(context).pop(simpleDialog);
      showSimpleCustomDialog(context, "Success",
          "Request has been sent successfully", "assets/success.gif");

      http.post(uploadUrl, body: {
        "image": base64String,
        "img_name": filename,
        "email": email
      }).then((result) {
        setStatus(result.body);
      }).catchError((error) {
        setStatus(error.toString());
        print(error.toString());
      });
      _makeAuth();
      setState(() {
        // isLoading = false;
      });
    } else {
      print('error connecting' + success.status);
    }
    // } else {
    //   print("error");
    // }
  }

  _makeAuth() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    var _user = shared_User.getStringList('user');

    var id = _user[0];
    String body;

    // set up POST request arguments
    String url = 'https://www.gohome.ng/_auth_user.php';
    Map<String, String> headers = {"Content-type": "application/json"};
    var s = '{"id": ' + " \"" + id + "\"" + ' }';
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

  changePassword() async {
    String newPassword = newPassController.text;
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    String oldPassword2 = passController.text;
    String confirmPassword = confirmPassController.text;

    var bytes = utf8.encode(oldPassword2);
    var oldPassDigest = sha1.convert(bytes);

    print("----------------------Password---------------------");
    print(oldPassword);
    print(oldPassDigest);
    print("----------------------Password---------------------");
    String body;
    if (passController.text.trim().isEmpty ||
        newPassController.text.trim().isEmpty ||
        confirmPassController.text.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "All Fields Are required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (oldPassword != oldPassDigest.toString()) {
      Fluttertoast.showToast(
          msg: "Invalid Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (newPassword != confirmPassword) {
      Fluttertoast.showToast(
          msg: "Password Confirmation Failed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      // set up POST request arguments
      String url = 'https://www.gohome.ng/_update_user_api.php';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = '{"password" : "${newPassword}", "user_id" : "${userId}" }';
      // make POST request

      print(json);
      Response response = await post(url, headers: headers, body: json);
      // Response response = await post(url, body: json);
      // check the status code for the result
      int statusCode = response.statusCode;
      // this API passes back the id of the new item added to the body
      body = response.body;

      print(body.toString());

      Success success = Success.fromJson(jsonDecode(body));
      if (success.status == "OK") {
        showSimpleCustomDialog(context, "Success",
            "Request has been sent successfully", "assets/success.gif");
        _makeAuth();
      } else {
        print('error connecting' + success.status);
      }
    }
  }

  void showSimpleCustomDialog(BuildContext context, String messageHead,
      String messageBody, String dialogType) {
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
                    Image.asset(
                      dialogType,
                      height: 100,
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
                      elevation: 0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok!',
                        style:
                            TextStyle(fontSize: 18.0, color: Color(0xFF79c942)),
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

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  List<String> fileNameList = List();

  startUpload() {
    _uploadingDialog(context);
    String filename;
    setStatus("Uploading...");
    if (null == tmpFile) {
      setStatus("error");
      // return;
      filename = user[2];
    } else {
      filename = tmpFile.path.split('/').last;
    }
    _updateUserProfile(filename);
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64String = base64Encode(snapshot.data.readAsBytesSync());
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: ClipOval(
              child: Image.file(
                snapshot.data,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.5,
                height: 200,
              ),
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            "Error selecting image",
            textAlign: TextAlign.center,
          );
        } else {
          return Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.85,
            child: CircleAvatar(
              child: Container(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/person.png",
                      image:
                          "https://www.gohome.ng/assets/images/agents/${user[1]}/${user[2]}",
                      fit: BoxFit.cover,
                    ),
                  )),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white38,
              maxRadius: 60,
            ),
          );
        }
      },
    );
    //  }
    // );
  }

  void _uploadingDialog(BuildContext context) {
    simpleDialog = Dialog(
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
                  children: <Widget>[CircularProgressIndicator()],
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

  Future<bool> _onBackPressed() async {
    // Your back press code here...
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Modify Profile"),
            backgroundColor: Color(0xFF79c942),
          ),
          body: Container(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: <Widget>[
                  TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        text: "Profile",
                      ),
                      Tab(
                        text: "Security",
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          showImage(),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              OutlineButton(
                                                onPressed: chooseImage,
                                                child: Text("Choose Image"),
                                              ),
                                            ],
                                          ),
                                          // Text(
                                          //   status,
                                          //   textAlign: TextAlign.center,
                                          //   style: TextStyle(
                                          //     color: Colors.green,
                                          //     fontWeight: FontWeight.w500,
                                          //     fontSize: 10.0,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      // Column(
                                      //   children: <Widget>[
                                      //     Container(
                                      //       child: IconButton(
                                      //         onPressed: null,
                                      //         icon: Icon(
                                      //           Icons.add,
                                      //           size: 45,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Text("Add Images"),
                                      //   ],
                                      // )
                                    ],
                                  ),
                                ),
                                // ),
                                Card(
                                    elevation: 20,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: userController,
                                              decoration: InputDecoration(
                                                  hintText: 'Username'),
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: TextFormField(
                                                controller: emailController,
                                                decoration: InputDecoration(
                                                    hintText: 'Email'),
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: phoneController,
                                              decoration: InputDecoration(
                                                  hintText: 'phone'),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: webController,
                                              decoration: InputDecoration(
                                                  hintText: 'Website'),
                                            ),
                                          ),
                                          RaisedButton(
                                            padding: EdgeInsets.all(15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: startUpload,
                                            color: Color(0xFF79c942),
                                            disabledColor: Color(0xFF79c942),
                                          )
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(
                                    elevation: 20,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: passController,
                                              decoration: InputDecoration(
                                                  hintText: 'Old Password',
                                                suffix: IconButton(
                                                  icon: Icon(
                                                    pass
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                  ),
                                                  onPressed: () => setState(() {
                                                    pass = !pass;
                                                  }),
                                                ),),
                                              obscureText: pass,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: newPassController,
                                              decoration: InputDecoration(
                                                hintText: 'New Password',
                                                suffix: IconButton(
                                                  icon: Icon(
                                                    newPass
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                  ),
                                                  onPressed: () => setState(() {
                                                    newPass = !newPass;
                                                  }),
                                                ),
                                              ),
                                              obscureText: newPass,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: TextFormField(
                                              controller: confirmPassController,
                                              decoration: InputDecoration(
                                                hintText: 'ConfirmPassword',
                                                suffix: IconButton(
                                                  icon: Icon(
                                                    confirmPass
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                  ),
                                                  onPressed: () => setState(() {
                                                    confirmPass = !confirmPass;
                                                  }),
                                                ),
                                              ),
                                              obscureText: confirmPass,
                                            ),
                                          ),
                                          RaisedButton(
                                            padding: EdgeInsets.all(15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: changePassword,
                                            color: Color(0xFF79c942),
                                            disabledColor: Color(0xFF79c942),
                                          )
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
