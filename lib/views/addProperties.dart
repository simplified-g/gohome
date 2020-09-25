import 'package:flutter/material.dart';
import 'package:go_home/classes/provider.dart';
import 'package:go_home/views/myProperties.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:go_home/classes/success.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';

import '../components/labelledInput.dart';

class AddProperties extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddPropertiesState();
}

class _AddPropertiesState extends State<AddProperties> {
  Future<File> file;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
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
      //    print("Done");
      sub.cancel();
    });
  }

  getUserDetails() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    // Map userMap = jsonDecode(shared_User.getString('user'));
    user = shared_User.getStringList('user');

    setState(() {
      user_id = user[0];
      user_email = user[1];
      //    print(user_email);
    });
  }

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
  String errMessage = "Error uploading Image";

  String propertyValue = "House";
  String saleOrRent = "Sale";
  String yesNo = "Yes"; //Garages
  String stateValue = "Lagos"; //State
  String lgaValue = "Any LGA";
  bool posting = false;

  //Controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController bedCountController = TextEditingController();
  TextEditingController bathCountController = TextEditingController();
  TextEditingController storeyController = TextEditingController();
  TextEditingController plotController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  List<String> features = List();
  List<Future<File>> fileList = List();
  List<File> tmpList = List();

  List bsList = [];

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  List<String> arr_check = [];
  List<String> arr_options = [
    "Center cooling",
    "Balcony",
    "Pet Friendly",
    "Fire alarm",
    "Storage",
    "Dryer",
    "Heating",
    "Pool",
    "Laundry",
    "Sauna",
    "Gym",
    "Elevator",
    "Dish washer",
    "Emergency Exit",
  ];

  setStatus(String message) {
    setState(() {
      // message.length != 0?
      // status = message.substring(0,20)
      // :
      status = message;
    });
  }

  checkValue(String val, List arr) {
    if (arr.length == 0) {
      return false;
    } else if (arr.contains(val)) {
      return true;
    } else {
      return false;
    }
  }

  List<String> fileNameList = List();

  MainProvider mainProvider = new MainProvider();

  startUpload() async {
    String title = titleController.text;
    String desc = descController.text;
    String bath = bathCountController.text;
    String bedroom = bedCountController.text;
    String storey = storeyController.text;
    String plot = plotController.text;
    String price = priceController.text;
    String address = addressController.text;
    String zip = zipController.text;

    if(titleController.text == '') {
      Fluttertoast.showToast(
          msg: "Title Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(bathCountController.text == '') {
      Fluttertoast.showToast(
          msg: "Bathrooms Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(bedCountController.text == '') {
      Fluttertoast.showToast(
          msg: "BedRooms Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(storeyController.text == '') {
      Fluttertoast.showToast(
          msg: "Story Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(plotController.text == '') {
      Fluttertoast.showToast(
          msg: "Plot Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(priceController.text == '') {
      Fluttertoast.showToast(
          msg: "Price Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(addressController.text == '') {
      Fluttertoast.showToast(
          msg: "Address Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if(titleController.text == '') {
      Fluttertoast.showToast(
          msg: "Title Required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    setState(() {
      posting = true;
    });


    String featureToString = features.join(',');
    String body;

    var data = {
      "user_id": user_id,
      "email": user_email,
      "prop_title": title,
      "prop_description": desc,
      "prop_type": propertyValue,
      "prop_status": saleOrRent,
      "bedrooms": bedroom,
      "bathrooms": bath,
      "floors": storey,
      "garage": yesNo,
      "prop_size": plot,
      "prop_price": price,
      "address": address,
      "state": stateValue,
      "Postal_code": zip,
      "features": arr_check.join(", "),
      "img1": await this.mainProvider.multipartFile(imageFiles[0]),
      "img2": await this.mainProvider.multipartFile(imageFiles[1]),
    };

    var postData = this.mainProvider.toDioData(data);
    var response = await this
        .mainProvider
        .dio
        .post('api/create_property_api.php', data: postData);
    //    print("Response: ${response.data}");
    if (response.data.toString().contains("New Property Added!")) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => MyProperties(user_id)));
    }
    setState(() {
      posting = false;
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  List<File> imageFiles = [new File(''), new File('')];
  imgUpload(File f) async {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text('Are you sure you want to upload an image'),
              actions: <Widget>[
                FlatButton(
                    child: Text(
                      'Cancel',
                    ),
                    onPressed: () => Navigator.of(context).pop(false)),
                FlatButton(
                    child: Text(
                      'Ok',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    }),
              ],
            )).then((response) async {
      if (response) {
        final File imageFile =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        setState(() {
          imageFiles[imageFiles.indexOf(f)] = imageFile;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool is_checked = true;
    final buttonColor = Theme.of(context).primaryColor;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Property"),
          backgroundColor: Color(0xFF79c942),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black12,
            padding: EdgeInsets.all(10),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Property Description",
                            style: TextStyle(fontSize: 25),
                          ),
                          LabelledInput(
                            controller: titleController,
                            hint: "Enter Property title",
                          ),
                          LabelledInput(
                            controller: descController,
                            hint: "Enter Property Description",
                            maxLines: 8,
                          ),
                          Text("Property Features"),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    DropdownButton<String>(
                                      value: propertyValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(color: Colors.black),
                                      underline: Container(
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          propertyValue = newValue;
                                        });
                                      },
                                      items: <String>[
                                        'House',
                                        'Office',
                                        'Store',
                                        'Land'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    DropdownButton<String>(
                                      value: saleOrRent,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(color: Colors.black),
                                      underline: Container(
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          saleOrRent = newValue;
                                        });
                                      },
                                      items: <String>['Sale', 'Rent']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: LabelledInput(
                              controller: bedCountController,
                              hint: "How many bedrooms",
                            ),
                          ),
                          Container(
                            child: LabelledInput(
                              controller: bathCountController,
                              hint: "How many bathrooms",
                            ),
                          ),
                          Container(
                            child: LabelledInput(
                              controller: storeyController,
                              hint: "How many Storey",
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text("Garage"),
                                DropdownButton<String>(
                                  isExpanded: true,
                                  value: yesNo,
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 0,
                                    color: Colors.black,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      yesNo = newValue;
                                    });
                                  },
                                  items: <String>[
                                    'Yes',
                                    'No'
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: LabelledInput(
                              controller: plotController,
                              hint: "Plots or Acres",
                            ),
                          ),
                          Container(
                            child: LabelledInput(
                              controller: priceController,
                              hint: "Sale or Rent Price",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text("Image Upload"),
                    subtitle: Text(
                        "You can only add two images. upon approval kindly visit your property page to add more images",
                        style: TextStyle(
                            color: Colors.red
                        ),
                    )
                  ),
                  Card(
                    child: Container(
                      height: 150,
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: imageFiles
                            .map(
                              (f) => InkWell(
                                onTap: () => this.imgUpload(f),
                                child: Container(
                                  child: f.path == ''
                                      ? Center(
                                          child: CircleAvatar(
                                            radius: 30,
                                            child: Icon(Icons.file_upload),
                                          ),
                                        )
                                      : Image.file(
                                          File(f.path),
                                          fit: BoxFit.fitHeight,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text("Property Features",
                              style: TextStyle(fontSize: 25)),
                          ...arr_options
                              .map(
                                (option) => ListTile(
                                  leading: Checkbox(
                                    activeColor: Color(0xFF79c942),
                                    value: arr_check.contains(option),
                                  ),
                                  title: Text(option),
                                  onTap: () {
                                    setState(() {
                                      if (arr_check.contains(option)) {
                                        arr_check.remove(option);
                                      } else {
                                        arr_check.add(option);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                  // Card(
                  //   child: Container(
                  //     child:
                  //   ),
                  // ),
                  // ),
                  Card(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Property Location",
                            style: TextStyle(fontSize: 25),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                LabelledInput(
                                  controller: addressController,
                                  hint: "Enter Property address",
                                ),
                                DropdownButton<String>(
                                  value: stateValue,
                                  icon: Icon(Icons.arrow_drop_down),
                                  isExpanded: true,
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 0,
                                    color: Colors.black,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      stateValue = newValue;
                                    });
                                  },
                                  items: <String>[
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
                                LabelledInput(
                                  controller: zipController,
                                  hint: "Enter the ZIP/Postal code",
                                ),
                                posting
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : MaterialButton(
                                        color: Color(0xFF79c942),
                                        onPressed: startUpload,
                                        child: Text("Submit"),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
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
