class chat_doc_only_user_chat {
  int? id;
  int? doctorPhoneNumber;
  int? phoneNumber;
  String? firstName;
  String? lastName;
  String? gender;
  int? age;
  String? email;
  String? location;
  String? userPhoto;
  int? patient;

  chat_doc_only_user_chat(
      {this.id,
        this.doctorPhoneNumber,
        this.phoneNumber,
        this.firstName,
        this.lastName,
        this.gender,
        this.age,
        this.email,
        this.location,
        this.userPhoto,
        this.patient});

  chat_doc_only_user_chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorPhoneNumber = json['doctor_phone_number'];
    phoneNumber = json['phone_number'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    age = json['age'];
    email = json['email'];
    location = json['location'];
    userPhoto = json['user_photo'];
    patient = json['patient'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_phone_number'] = this.doctorPhoneNumber;
    data['phone_number'] = this.phoneNumber;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['email'] = this.email;
    data['location'] = this.location;
    data['user_photo'] = this.userPhoto;
    data['patient'] = this.patient;
    return data;
  }
}
