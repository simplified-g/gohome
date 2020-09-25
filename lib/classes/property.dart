import 'package:go_home/classes/provider.dart';
import 'package:dio/dio.dart';

class Property {
  String id;
  String prop_id;
  String user_id;
  String user_email;
  String title;
  String description;
  String amount;
  String propType;
  String saleOrRent;
  String bedroom;
  String bathroom;
  String floors;
  String garages;
  String size;
  String name;
  String phone;
  String address;
  String region;
  String state;
  String approved;
  String postalCode;
  List<String> features;
  String img1;
  String img2;
  String img3;
  String img4;
  String img5;
  String img6;
  String img7;
  String img8;
  String img9;
  String img10;
  String img11;
  String img12;
  String img13;
  String img14;
  String img15;
  String status;
  String createdAt;
  bool isFav;
  String featured;

  Property(
      {this.id,
      this.amount,
      this.propType,
      this.bedroom,
      this.bathroom,
      this.prop_id,
      this.user_id,
      this.user_email,
      this.name,
      this.phone,
      this.address,
      this.region,
      this.state,
      this.title,
      this.saleOrRent,
      this.description,
      this.img1,
      this.img2,
      this.status,
      this.img3,
      this.img4,
      this.img5,
      this.img6,
      this.img7,
      this.img8,
      this.img9,
      this.img10,
      this.img11,
      this.img12,
      this.img13,
      this.img14,
      this.img15,
      this.createdAt,
      this.isFav,
      this.floors,
      this.garages,
      this.size,
        this.postalCode,
        this.featured,
        this.approved,
      this.features});

  factory Property.fromJson(Map<String, dynamic> json) {
    //    print(json);
    return Property(
        id: json['id'] as String,
        amount: json['amount'] as String,
        propType: json['type'] as String,
        bedroom: json['bedrooms'] as String,
        bathroom: json['bathrooms'] as String,
        prop_id: json['prop_id'] as String,
        user_id: json['user_id'] as String,
        user_email: json['user_email'] as String,
        phone: json['phone'] as String,
        name: json['username'] as String,
        address: json['address'] as String,
        region: json['region'] as String,
        state: json['state'] as String,
        saleOrRent: json['status'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        floors: json['floors'] as String,
        garages: json['garages'] as String,
        size: json['size'] as String,
        approved: json['approved'] as String,
        featured: json['featured'] as String,
        postalCode: json['postal_code'] as String,
        features: json['features'].toString().split(", "),
        img1: json['img1'] as String,
        img2: json['img2'] as String,
        img3: json['img3'] as String,
        img4: json['img4'] as String,
        img5: json['img5'] as String,
        img6: json['img6'] as String,
        img7: json['img7'] as String,
        img8: json['img8'] as String,
        img9: json['img9'] as String,
        img10: json['img10'] as String,
        img11: json['img11'] as String,
        img12: json['img12'] as String,
        img13: json['img13'] as String,
        img14: json['img14'] as String,
        img15: json['img15'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
        isFav: json['isFav'] as bool);
  }

  @override
  String toString() {
    return '{ ${this.amount}, ${this.phone}, ${this.name}, ${this.title}, ${this.status}, $createdAt }';
  }

  String image(int img) {
    switch (img) {
      case (1):
        return this.img1;
      case (2):
        return this.img2;
      case (3):
        return this.img3;
      case (4):
        return this.img4;
      case (5):
        return this.img5;
      case (6):
        return this.img6;
      case (7):
        return this.img7;
      case (8):
        return this.img8;
      case (9):
        return this.img9;
      case (10):
        return this.img10;
      case (11):
        return this.img11;
      case (12):
        return this.img12;
      case (13):
        return this.img13;
      case (14):
        return this.img14;
      case (15):
        return this.img15;
      default:
        return this.img1;
    }
  }

  void setImage(int imgNo, String img) {
    switch (imgNo) {
      case (1):
        this.img1 = img;
        break;
      case (2):
        this.img2 = img;
        break;
      case (3):
        this.img3 = img;
        break;
      case (4):
        this.img4 = img;
        break;
      case (5):
        this.img5 = img;
        break;
      case (6):
        this.img6 = img;
        break;
      case (7):
        this.img7 = img;
        break;
      case (8):
        this.img8 = img;
        break;
      case (9):
        this.img9 = img;
        break;
      case (10):
        this.img10 = img;
        break;
      case (11):
        this.img11 = img;
        break;
      case (12):
        this.img12 = img;
        break;
      case (13):
        this.img13 = img;
        break;
      case (14):
        this.img14 = img;
        break;
      case (15):
        this.img15 = img;
        break;
      default:
        this.img1 = img;
    }
  }

  MainProvider mainProvider = new MainProvider();

  Future<bool> checkImg(int img) async {
    String imgStr = image(img);
    try {
      var response = await this
          .mainProvider
          .dio
          .head("assets/upload/" + this.prop_id + "/" + imgStr);
      if (response.statusCode == 200) return true;
      return false;
    } on DioError catch (e) {
      return false;
    }
  }
}
