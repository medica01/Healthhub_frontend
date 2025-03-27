import 'package:flutter/material.dart';

class show_spe_order_pro extends StatefulWidget {
  final dynamic product_number;

  show_spe_order_pro({super.key, required this.product_number});

  @override
  State<show_spe_order_pro> createState() => _show_spe_order_proState();
}

class _show_spe_order_proState extends State<show_spe_order_pro> {
  Widget option(String name) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10)),
        height: 65,
        width: 170,
        child: Center(
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15.0,
                right: 10,
              ),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Arriving order day",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "See all orders",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 0.1)),
                      width: 350,
                      // height: 43,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image.network(
                              scale: 4,
                              "https://media.gettyimages.com/id/1280723508/photo/cough-syrup-isolated-on-white-background.jpg?s=612x612&w=gi&k=20&c=cQhZdhzsduFa-e-F4glwWCOHRmOaA2-ZWY_F_Frv3ks=")),
                    ),
                    Container(
                      height: 150,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child:
                              option("Update delivery \n    Instructions"),
                            ),
                            option("Buy Again"),
                            option("Cancel Order")
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1)),
                        child: ListTile(
                          title: Text(
                            "Shipping Address",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("gokulraj"),
                                Text(
                                    "274, siruvathur road, Anguchettipalayam, Panruti"),
                                Text(
                                    "Siruvathur Road, Anguchettipalayam, Panruti"),
                                Text("Panruti, Tamil Nadu"),
                                Text("607 106")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: ListTile(
                        title: Text(
                          "Order Info",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 5,
                              endIndent: 5,
                            ),
                            ListTile(
                              title: Text("View order details"),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 3,
                              endIndent: 3,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Items from your Wish List",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.more_vert))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 100,
            )
          ],
        ),

    );
  }
}
