import 'dart:ffi';

class MyUser {
  MyUser({
    required this.image,
    required this.name,
    required this.disorder,
    required this.id,
    required this.email,
    required this.age,
    required this.gender,
    required this.classType
  });
  late String image;
  late String name;
  late String disorder;
  late String id;
  late String email;
  late String age;
  late String gender;
  late String classType;

  MyUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    name = json['name']?? '';
    disorder = json['disorder']?? '';
    id = json['id']?? '';
    email = json['email']?? '';
    age = json['age']?? '';
    gender = json['gender']?? '';
    classType = json['classType']?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['name'] = name;
    _data['disorder'] = disorder;
    _data['id'] = id;
    _data['email'] = email;
    _data['age'] = age;
    _data['gender'] = gender;
    _data['classType'] = classType;
    return _data;
  }
}


