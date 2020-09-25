import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_home/classes/property.dart';
import 'package:go_home/classes/provider.dart';
import 'package:go_home/views/myProperties.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:go_home/classes/success.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiver/async.dart';

import '../components/labelledInput.dart';

class EditProperty extends StatefulWidget {
  final Property property;

  const EditProperty({Key key, this.property}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditPropertyState(this.property);
}

class _EditPropertyState extends State<EditProperty> {
  final Property property;

  Future<File> file;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  List user;
  String user_id, user_email;

  int _start = 10;
  int _current = 10;

  _EditPropertyState(this.property);

  getUserDetails() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    // Map userMap = jsonDecode(shared_User.getString('user'));
    user = shared_User.getStringList('user');

    setState(() {
      user_id = user[0];
      user_email = user[1];
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();

    this.propertyValue = this.property.propType;
    this.saleOrRent = this.property.saleOrRent;
    this.stateValue = this.property.state; //State

    this.bedCountController.text = this.property.bedroom;
    this.titleController.text = this.property.title;
    this.descController.text = this.property.description;
    this.bathCountController.text = this.property.bathroom;
    this.priceController.text = this.property.amount;
    this.addressController.text = this.property.address;
    this.arr_check = this.property.features;
  }

  void downSet()
  {
    this.property.propType =  this.propertyValue;
    this.property.saleOrRent = this.saleOrRent;
    this.property.state = this.stateValue; //State

    this.property.bedroom = this.bedCountController.text;
    this.property.title = this.titleController.text;
    this.property.description = this.descController.text;
    this.property.bathroom = this.bathCountController.text;
    this.property.amount = this.priceController.text;
    this.property.address = this.addressController.text;
    this.property.features = this.arr_check;
  }

  String propertyValue = "House";
  String saleOrRent = "Sale";
  String yesNo = "Yes"; //Garages
  String stateValue = "Lagos"; //State
  bool posting = false;

  //Controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController bathCountController = TextEditingController();
  TextEditingController bedCountController = TextEditingController();
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

  MainProvider mainProvider = new MainProvider();

  imgUpload(int img) async {
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
        if (imageFile != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          var data = {
            "image": await this.mainProvider.multipartFile(imageFile),
            "img": "img$img",
            "prop_id": this.property.prop_id
          };

          var postData = this.mainProvider.toDioData(data);
          var response = await this
              .mainProvider
              .dio
              .post('api/upload_property_image_api.php', data: postData);

          setState((){
            this.property.setImage(img, response.data);
          });
        }
      }
      Navigator.of(context).pop();
    });
  }

  startUpload() async {
    setState(() {
      posting = true;
    });

    String featureToString = features.join(',');
    String body;
    String title = titleController.text;
    String desc = descController.text;
    String bath = bathCountController.text;
    String bedroom = bedCountController.text;
    String storey = storeyController.text;
    String plot = plotController.text;
    String price = priceController.text;
    String address = addressController.text;
    String zip = zipController.text;

    var data = {
      "user_id": user_id,
      "id": property.id,
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
      "features": arr_check.join(", ")
    };

    var postData = this.mainProvider.toDioData(data);
    var response = await this
        .mainProvider
        .dio
        .post('api/update_property_api.php', data: postData);
    if(response.data.toString().contains("Property Updated!")){
      downSet();
    }

    Fluttertoast.showToast(
        msg: response.data,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    print(response.data);
    print("----------------------------------------");
    setState(() {
      posting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool is_checked = true;
    final buttonColor = Theme.of(context).primaryColor;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(property.title),
          backgroundColor: Color(0xFF79c942),
        ),
        body: DefaultTabController(
            length: 2,
            child: Container(
              child: Column(
                children: <Widget>[
                  TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                          child: Text("Details"),
                        ),
                        Tab(
                          child: Text("Images"),
                        )
                      ]),
                  Expanded(
                    child: Container(
                      child: TabBarView(
                        children: <Widget>[
                          SingleChildScrollView(
                            child: Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(10),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    DropdownButton<String>(
                                                      value: propertyValue,
                                                      icon: Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 24,
                                                      elevation: 16,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      underline: Container(
                                                        height: 0,
                                                        color: Colors.black,
                                                      ),
                                                      onChanged:
                                                          (String newValue) {
                                                        setState(() {
                                                          propertyValue =
                                                              newValue;
                                                        });
                                                      },
                                                      items: <String>[
                                                        'House',
                                                        'Office',
                                                        'Store',
                                                        'Land'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    DropdownButton<String>(
                                                      value: saleOrRent,
                                                      icon: Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 24,
                                                      elevation: 16,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      underline: Container(
                                                        height: 0,
                                                        color: Colors.black,
                                                      ),
                                                      onChanged:
                                                          (String newValue) {
                                                        setState(() {
                                                          saleOrRent = newValue;
                                                        });
                                                      },
                                                      items: <String>[
                                                        'Sale',
                                                        'Rent'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
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
                                              controller: priceController,
                                              hint: "Sale or Rent Price",
                                            ),
                                          ),
                                        ],
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
                                                    activeColor:
                                                        Color(0xFF79c942),
                                                    value: arr_check
                                                        .contains(option),
                                                  ),
                                                  title: Text(option),
                                                  onTap: () {
                                                    setState(() {
                                                      if (arr_check
                                                          .contains(option)) {
                                                        arr_check
                                                            .remove(option);
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
                                                  hint:
                                                      "Enter Property address",
                                                ),
                                                DropdownButton<String>(
                                                  value: stateValue,
                                                  icon: Icon(
                                                      Icons.arrow_drop_down),
                                                  isExpanded: true,
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: Colors.black),
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
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                                posting
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )
                                                    : MaterialButton(
                                                        color:
                                                            Color(0xFF79c942),
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
                          Container(
                            child: GridView.count(
                              crossAxisCount: 2,
                              children: List<int>.generate(10, (i) => i + 1)
                                  .map((f) => InkWell(
                                        onTap: () => this.imgUpload(f),
                                        child: Container(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "http://gohome.ng/assets/upload/" +
                                                    property.prop_id +
                                                    "/" +
                                                    property.image(f),
                                            placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    new Image(
                                              image: AssetImage(
                                                  "assets/property_location.jpg"),
                                              width: 100,
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
