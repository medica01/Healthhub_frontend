class show_booking_doc_chat_user {
  int? id;
  String? doctorName;
  int? patientPhoneNumber;
  int? doctorPhoneNo;
  String? doctorEmail;
  String? specialty;
  int? service;
  int? age;
  String? gender;
  String? language;
  String? doctorImage;
  String? qualification;
  String? bio;
  int? regNo;
  String? doctorLocation;
  int? doctor;

  show_booking_doc_chat_user(
      {this.id,
        this.doctorName,
        this.patientPhoneNumber,
        this.doctorPhoneNo,
        this.doctorEmail,
        this.specialty,
        this.service,
        this.age,
        this.gender,
        this.language,
        this.doctorImage,
        this.qualification,
        this.bio,
        this.regNo,
        this.doctorLocation,
        this.doctor});

  show_booking_doc_chat_user.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorName = json['doctor_name'];
    patientPhoneNumber = json['patient_phone_number'];
    doctorPhoneNo = json['doctor_phone_no'];
    doctorEmail = json['doctor_email'];
    specialty = json['specialty'];
    service = json['service'];
    age = json['age'];
    gender = json['gender'];
    language = json['language'];
    doctorImage = json['doctor_image'];
    qualification = json['qualification'];
    bio = json['bio'];
    regNo = json['reg_no'];
    doctorLocation = json['doctor_location'];
    doctor = json['doctor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_name'] = this.doctorName;
    data['patient_phone_number'] = this.patientPhoneNumber;
    data['doctor_phone_no'] = this.doctorPhoneNo;
    data['doctor_email'] = this.doctorEmail;
    data['specialty'] = this.specialty;
    data['service'] = this.service;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['language'] = this.language;
    data['doctor_image'] = this.doctorImage;
    data['qualification'] = this.qualification;
    data['bio'] = this.bio;
    data['reg_no'] = this.regNo;
    data['doctor_location'] = this.doctorLocation;
    data['doctor'] = this.doctor;
    return data;
  }
}
