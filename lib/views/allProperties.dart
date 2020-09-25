import 'package:flutter/material.dart';
import 'dart:async';
import 'package:quiver/async.dart';
import 'package:async/async.dart';

import '../services/services.dart';
import '../classes/property.dart';
import '../components/propertyList.dart';
import 'eachProperty.dart';

class AllProperties extends StatefulWidget {
  AllProperties() : super();

  @override
  State<StatefulWidget> createState() => _AllPropertiesState();
}

class _AllPropertiesState extends State<AllProperties> {
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

  final AsyncMemoizer _memoizer = AsyncMemoizer();

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

  final snackBar = SnackBar(
    content: Text('Please set the filter'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    startTimer();
    isButtonDisabled = true;
    this._memoizer.runOnce(() async {
      Services.getProperties().then((propertiesFromServer) {
        setState(() {
          properties = propertiesFromServer;
          filteredProperties = properties;
       //    print(properties);
        });
      });
    });
  }

  Future<void> reload() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AllProperties()));
    return null;
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
    if (typeValue != null && typeValue.trim().isNotEmpty &&
        typeValue != "Any Property Type") {
      tempProperty = tempProperty
          .where(
              (p) => p.propType.toLowerCase().contains(typeValue.toLowerCase()))
          .toList();
    }
    if (statusValue != null && statusValue.trim().isNotEmpty && statusValue
        != 'Any Status') {
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

  Future<void> refresh() async {
    setState(() {
      filteredProperties = properties;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Properties"),
        backgroundColor: Color(0xFF79c942),
        key: GlobalKey(debugLabel: "sca"),
      ),
      body: filteredProperties.length < 1 && _current > 0
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Color(0xFF79c942),
            ))
          : filteredProperties.length < 1 && _current == 0
              ? RefreshIndicator(
                  onRefresh: reload,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Text(
                        "No result found. Please check your data connection !"),
                  ))
              : RefreshIndicator(
                  onRefresh: refresh,
                  child: Column(
                    children: <Widget>[
                      Container(
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
                      ),
                      filteredProperties.length > 0
                          ? Expanded(
                              child: ListView.builder(
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
                              ),
                            )
                          : CircularProgressIndicator(
                              backgroundColor: Color(0xFF79c942),
                            ),
                    ],
                  ),
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
                          items: <String>['Any Property Type','House', 'Offic'
                              'e', 'Store', 'Land']
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
                          items: <String>['Any Status','Sale', 'Rent']
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

class isButtonDisabled {}
