class on_off {
  int? id;
  bool? onOff;
  String? lastTime;

  on_off({this.id, this.onOff, this.lastTime});

  on_off.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    onOff = json['on_off'];
    lastTime = json['last_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['on_off'] = this.onOff;
    data['last_time'] = this.lastTime;
    return data;
  }
}
