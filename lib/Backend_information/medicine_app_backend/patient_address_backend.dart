class patient_address {
  int? id;
  String? fullName;
  int? pryPhoneNumber;
  int? secPhoneNumber;
  String? flatHouseName;
  String? areaBuildingName;
  String? landmark;
  int? pincode;
  String? townCity;
  String? stateName;
  int? sequenceNumber;

  patient_address(
      {this.id,
        this.fullName,
        this.pryPhoneNumber,
        this.secPhoneNumber,
        this.flatHouseName,
        this.areaBuildingName,
        this.landmark,
        this.pincode,
        this.townCity,
        this.stateName,
        this.sequenceNumber});

  patient_address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    pryPhoneNumber = json['pry_phone_number'];
    secPhoneNumber = json['sec_phone_number'];
    flatHouseName = json['flat_house_name'];
    areaBuildingName = json['area_building_name'];
    landmark = json['landmark'];
    pincode = json['pincode'];
    townCity = json['town_city'];
    stateName = json['state_name'];
    sequenceNumber = json['sequence_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['full_name'] = this.fullName;
    data['pry_phone_number'] = this.pryPhoneNumber;
    data['sec_phone_number'] = this.secPhoneNumber;
    data['flat_house_name'] = this.flatHouseName;
    data['area_building_name'] = this.areaBuildingName;
    data['landmark'] = this.landmark;
    data['pincode'] = this.pincode;
    data['town_city'] = this.townCity;
    data['state_name'] = this.stateName;
    data['sequence_number'] = this.sequenceNumber;
    return data;
  }
}
