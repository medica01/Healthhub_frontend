class order_placed_details {
  int? id;
  String? productName;
  int? productNumber;
  int? quantity;
  int? price;
  int? purchaseQuantity;
  int? purchaseTotalPrice;
  String? purchasePayType;
  String? cureDisases;
  String? productImage;
  String? aboutProduct;
  String? productType;
  String? orderDate;
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
  int? productDetails;
  int? userDetails;

  order_placed_details(
      {this.id,
        this.productName,
        this.productNumber,
        this.quantity,
        this.price,
        this.purchaseQuantity,
        this.purchaseTotalPrice,
        this.purchasePayType,
        this.cureDisases,
        this.productImage,
        this.aboutProduct,
        this.productType,
        this.orderDate,
        this.fullName,
        this.pryPhoneNumber,
        this.secPhoneNumber,
        this.flatHouseName,
        this.areaBuildingName,
        this.landmark,
        this.pincode,
        this.townCity,
        this.stateName,
        this.sequenceNumber,
        this.productDetails,
        this.userDetails});

  order_placed_details.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    productNumber = json['product_number'];
    quantity = json['quantity'];
    price = json['price'];
    purchaseQuantity = json['purchase_quantity'];
    purchaseTotalPrice = json['purchase_total_price'];
    purchasePayType = json['purchase_pay_type'];
    orderDate=json['order_date'];
    cureDisases = json['cure_disases'];
    productImage = json['product_image'];
    aboutProduct = json['about_product'];
    productType = json['product_type'];
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
    productDetails = json['product_details'];
    userDetails = json['user_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_name'] = this.productName;
    data['product_number'] = this.productNumber;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['purchase_quantity'] = this.purchaseQuantity;
    data['purchase_total_price'] = this.purchaseTotalPrice;
    data['purchase_pay_type'] = this.purchasePayType;
    data['order_date']=this.orderDate;
    data['cure_disases'] = this.cureDisases;
    data['product_image'] = this.productImage;
    data['about_product'] = this.aboutProduct;
    data['product_type'] = this.productType;
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
    data['product_details'] = this.productDetails;
    data['user_details'] = this.userDetails;
    return data;
  }
}
