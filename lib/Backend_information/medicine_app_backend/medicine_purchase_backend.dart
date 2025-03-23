class medicine_purchase {
  int? id;
  String? productName;
  int? productNumber;
  int? quantity;
  int? price;
  String? cureDisases;
  String? productImage;
  String? aboutProduct;

  medicine_purchase(
      {this.id,
        this.productName,
        this.productNumber,
        this.quantity,
        this.price,
        this.cureDisases,
        this.productImage,
        this.aboutProduct});

  medicine_purchase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    productNumber = json['product_number'];
    quantity = json['quantity'];
    price = json['price'];
    cureDisases = json['cure_disases'];
    productImage = json['product_image'];
    aboutProduct = json['about_product'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_name'] = this.productName;
    data['product_number'] = this.productNumber;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['cure_disases'] = this.cureDisases;
    data['product_image'] = this.productImage;
    data['about_product'] = this.aboutProduct;
    return data;
  }
}
