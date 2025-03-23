class add_to_carts {
  int? id;
  int? pryPhoneNumber;
  String? productName;
  int? productNumber;
  int? quantity;
  int? price;
  String? cureDisases;
  String? productImage;
  String? aboutProduct;
  String? productType;
  int? products;

  add_to_carts(
      {this.id,
        this.pryPhoneNumber,
        this.productName,
        this.productNumber,
        this.quantity,
        this.price,
        this.cureDisases,
        this.productImage,
        this.aboutProduct,
        this.productType,
        this.products});

  add_to_carts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pryPhoneNumber = json['pry_phone_number'];
    productName = json['product_name'];
    productNumber = json['product_number'];
    quantity = json['quantity'];
    price = json['price'];
    cureDisases = json['cure_disases'];
    productImage = json['product_image'];
    aboutProduct = json['about_product'];
    productType = json['product_type'];
    products = json['products'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pry_phone_number'] = this.pryPhoneNumber;
    data['product_name'] = this.productName;
    data['product_number'] = this.productNumber;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['cure_disases'] = this.cureDisases;
    data['product_image'] = this.productImage;
    data['about_product'] = this.aboutProduct;
    data['product_type'] = this.productType;
    data['products'] = this.products;
    return data;
  }
}
