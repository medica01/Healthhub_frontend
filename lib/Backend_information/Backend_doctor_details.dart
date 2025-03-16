class doctor_details {
  int? id;
  String? doctorName;
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
  bool? like;
  bool? docStatus;

  doctor_details(
      {this.id,
        this.doctorName,
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
        this.like,
        this.docStatus});

  doctor_details.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorName = json['doctor_name'];
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
    like = json['like'];
    docStatus = json['doc_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_name'] = this.doctorName;
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
    data['like'] = this.like;
    data['doc_status'] = this.docStatus;
    return data;
  }
}
