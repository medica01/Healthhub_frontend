class booking_doctor {
  int? id;
  String? bookingDate;
  String? bookingTime;
  String? createdAt;
  int? phoneNumber;
  String? doctorName;
  String? specialty;
  int? service;
  String? language;
  String? doctorImage;
  String? qualification;
  String? bio;
  int? regNo;
  String? doctorLocation;
  String? firstName;
  String? lastName;
  String? gender;
  String? docGender;
  int? age;
  int? docAge;
  int? docPhoneNumber;
  String? email;
  String? docEmail;
  String? location;
  String? userPhoto;
  int? patient;
  int? doctor;

  booking_doctor(
      {this.id,
        this.bookingDate,
        this.bookingTime,
        this.createdAt,
        this.phoneNumber,
        this.doctorName,
        this.specialty,
        this.service,
        this.language,
        this.doctorImage,
        this.qualification,
        this.bio,
        this.regNo,
        this.doctorLocation,
        this.firstName,
        this.lastName,
        this.gender,
        this.docGender,
        this.age,
        this.docAge,
        this.docPhoneNumber,
        this.email,
        this.docEmail,
        this.location,
        this.userPhoto,
        this.patient,
        this.doctor});

  booking_doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    createdAt = json['created_at'];
    phoneNumber = json['phone_number'];
    doctorName = json['doctor_name'];
    specialty = json['specialty'];
    service = json['service'];
    language = json['language'];
    doctorImage = json['doctor_image'];
    qualification = json['qualification'];
    bio = json['bio'];
    regNo = json['reg_no'];
    doctorLocation = json['doctor_location'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    docGender = json['doc_gender'];
    age = json['age'];
    docAge = json['doc_age'];
    docPhoneNumber = json['doc_phone_number'];
    email = json['email'];
    docEmail = json['doc_email'];
    location = json['location'];
    userPhoto = json['user_photo'];
    patient = json['patient'];
    doctor = json['doctor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_date'] = this.bookingDate;
    data['booking_time'] = this.bookingTime;
    data['created_at'] = this.createdAt;
    data['phone_number'] = this.phoneNumber;
    data['doctor_name'] = this.doctorName;
    data['specialty'] = this.specialty;
    data['service'] = this.service;
    data['language'] = this.language;
    data['doctor_image'] = this.doctorImage;
    data['qualification'] = this.qualification;
    data['bio'] = this.bio;
    data['reg_no'] = this.regNo;
    data['doctor_location'] = this.doctorLocation;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['doc_gender'] = this.docGender;
    data['age'] = this.age;
    data['doc_age'] = this.docAge;
    data['doc_phone_number'] = this.docPhoneNumber;
    data['email'] = this.email;
    data['doc_email'] = this.docEmail;
    data['location'] = this.location;
    data['user_photo'] = this.userPhoto;
    data['patient'] = this.patient;
    data['doctor'] = this.doctor;
    return data;
  }
}
