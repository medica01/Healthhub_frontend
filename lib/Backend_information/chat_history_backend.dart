class chat_history {
  int? id;
  int? userPhoneNo;
  int? docPhoneNo;
  String? senderType;
  String? message;
  String? image;
  String? datestamp;
  String? timestamp;

  chat_history(
      {this.id,
        this.userPhoneNo,
        this.docPhoneNo,
        this.senderType,
        this.message,
        this.image,
        this.datestamp,
        this.timestamp});

  chat_history.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userPhoneNo = json['user_phone_no'];
    docPhoneNo = json['doc_phone_no'];
    senderType = json['sender_type'];
    message = json['message'];
    image = json['image'];
    datestamp = json['datestamp'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_phone_no'] = this.userPhoneNo;
    data['doc_phone_no'] = this.docPhoneNo;
    data['sender_type'] = this.senderType;
    data['message'] = this.message;
    data['image'] = this.image;
    data['datestamp'] = this.datestamp;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
