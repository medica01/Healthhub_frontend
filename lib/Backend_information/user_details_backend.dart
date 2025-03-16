class update_profile {
  int? id;
  String? createdAt;
  String? firstName;
  String? lastName;
  String? gender;
  int? age;
  int? phoneNumber;
  String? email;
  String? location;
  String? userPhoto;
  bool? userStatus;

  update_profile(
      {this.id,
        this.createdAt,
        this.firstName,
        this.lastName,
        this.gender,
        this.age,
        this.phoneNumber,
        this.email,
        this.location,
        this.userPhoto,
        this.userStatus});

  update_profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    age = json['age'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    location = json['location'];
    userPhoto = json['user_photo'];
    userStatus = json['user_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['location'] = this.location;
    data['user_photo'] = this.userPhoto;
    data['user_status'] = this.userStatus;
    return data;
  }
}
