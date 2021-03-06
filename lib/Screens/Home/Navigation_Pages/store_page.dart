import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/Components/custom_button_widget.dart';
import 'package:grocery_app/Screens/Store/my_store_screen.dart';
import 'package:grocery_app/Screens/Store/store_details_screen.dart';
import 'package:grocery_app/Screens/Store/store_notifications_screen.dart';
import 'package:grocery_app/utilities/alert_box.dart';
import 'package:grocery_app/utilities/constants.dart';
import 'package:grocery_app/utilities/store_api.dart';
import 'package:grocery_app/utilities/user_api.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();

  final Widget leadingWidget;
  const StorePage({@required this.leadingWidget});
}

class _StorePageState extends State<StorePage> {

  UserApi userApi = UserApi.instance;
  bool darkAppBarIcons = false;
  bool isStoreAvailable = false;
  // Display progress indicator until data is loaded
  Widget storePageDisplay = Center(
    child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(kColorPurple),
    ),
  );

  /*
  Function to load store details from database
   */
  Future<void> loadStoreData(DocumentSnapshot snapshot) async {
    Map<String, dynamic> data = snapshot.data();

    // Save all the data in store api class
    StoreApi storeApi = StoreApi.instance;
    storeApi.name = data['name'];
    storeApi.ownerName = data['ownerName'];
    storeApi.ownerEmail = data['ownerEmail'];
    storeApi.ownerContact = data['ownerContact'];
    storeApi.latitude = data['latitude'];
    storeApi.longitude = data['longitude'];
    storeApi.address = data['address'];
    storeApi.rating = data['rating'];
    storeApi.reviews = data['reviews'];
    storeApi.orders = data['orders'];
    storeApi.city = data['city'];
    storeApi.country = data['country'];
  }

  /*
  Function to load details of the seller from database
   */
  Future<void> getSellerDetails() async {
    // ignore: deprecated_member_use
    await Firestore.instance
        .collection('Sellers')
        .doc(userApi.email)
        .get()
        .then((snapshot) async {
      // Snapshot loaded
      if (snapshot.exists) {
        // Data present - Seller registered
        isStoreAvailable = true;
        await loadStoreData(snapshot);
        storePageDisplay = MyStoreScreen();
        darkAppBarIcons = false;
        setState(() {});
      } else {
        // Data absent - Seller not registered
        // Replace loading indicator with button
        isStoreAvailable = false;
        darkAppBarIcons = true;
        storePageDisplay = Center(
          child: CustomButtonWidget(
            label: 'Open your store',
            onPressed: () {
              // Open store details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreDetailsScreen(),
                ),
              ).then((value) async {
                if (value == 'SUCCESS') {
                  // Display store screen after successfull registration
                  storePageDisplay = MyStoreScreen();
                  setState(() {});
                }
              });
            },
          ),
        );
        setState(() {});
      }
    }).catchError((error) {
      // Error in fetching the document
      AlertBox.showMessageDialog(
          context, 'Error', 'Unable to reach store.\n${error.message}');
    });
  }

  @override
  void initState() {
    super.initState();
    getSellerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: darkAppBarIcons ? kColorPurple : kColorWhite,
        ),
        backgroundColor: darkAppBarIcons ? kColorWhite : kColorPurple,
        elevation: 0,
        leading: widget.leadingWidget,
        actions: [
          isStoreAvailable ?IconButton(
              icon: Icon(
                Icons.notifications,
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => StoreNotificationsScreen()));
              },
          ) : Container(),
        ],
        centerTitle: true,
        title: Text(
          'My Store',
          style: TextStyle(
            color: darkAppBarIcons ? kColorPurple : kColorWhite,
            fontSize: 24,
          ),
        ),
      ),
      body: storePageDisplay,
    );
  }
}
