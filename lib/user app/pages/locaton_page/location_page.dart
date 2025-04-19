// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class MapRouteApp extends StatefulWidget {
//   @override
//   _MapRouteAppState createState() => _MapRouteAppState();
// }
//
// class _MapRouteAppState extends State<MapRouteApp> {
//   GoogleMapController? _mapController;
//   TextEditingController sourceController = TextEditingController();
//   TextEditingController destinationController = TextEditingController();
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   LatLng? _currentLocation;
//   double _distance = 0.0; // Add this variable in your state
//   String orsApiKey =
//       "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"; // Replace with your ORS API key
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     // Request location permission
//     var status = await Permission.location.request();
//     if (status.isGranted) {
//       // Permission granted, get current location
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//         _markers.add(Marker(
//           markerId: MarkerId("current"),
//           position: _currentLocation!,
//           infoWindow: InfoWindow(title: "Your Location"),
//         ));
//       });
//
//       // Move map camera to current location
//       _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
//     } else if (status.isDenied) {
//       // If permission is denied, show message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Location permission is required")),
//       );
//     } else if (status.isPermanentlyDenied) {
//       // If permission is permanently denied, open settings
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text("Please enable location permission in settings")),
//       );
//       openAppSettings();
//     }
//   }
//
//   void _findRoute() async {
//     String source = sourceController.text.trim();
//     String destination = destinationController.text.trim();
//
//     if (source.isEmpty || destination.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enter both source and destination")),
//       );
//       return;
//     }
//
//     try {
//       List<String> sourceLatLng = source.split(",");
//       List<String> destLatLng = destination.split(",");
//
//       double sourceLat = double.parse(sourceLatLng[0]);
//       double sourceLng = double.parse(sourceLatLng[1]);
//       double destLat = double.parse(destLatLng[0]);
//       double destLng = double.parse(destLatLng[1]);
//
//       LatLng sourcePosition = LatLng(sourceLat, sourceLng);
//       LatLng destinationPosition = LatLng(destLat, destLng);
//
//       // Clear previous markers and polylines
//       _markers.clear();
//       _polylines.clear();
//
//       // Add markers for source and destination
//       _markers.add(Marker(
//         markerId: MarkerId("source"),
//         position: sourcePosition,
//         infoWindow: InfoWindow(title: "Source"),
//       ));
//       _markers.add(Marker(
//         markerId: MarkerId("destination"),
//         position: destinationPosition,
//         infoWindow: InfoWindow(title: "Destination"),
//       ));
//
//       // Use OSRM free public API for routing
//       String url =
//           "http://router.project-osrm.org/route/v1/driving/$sourceLng,$sourceLat;$destLng,$destLat?overview=full&geometries=polyline"; // OSRM free routing API
//
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = json.decode(response.body);
//
//         if (data['routes'].isNotEmpty) {
//           List<LatLng> polylineCoordinates = [];
//
//           // Extract polyline points from the response
//           var geometry = data['routes'][0]['geometry'];
//           polylineCoordinates.addAll(_decodePolyline(geometry));
//
//           // Add the polyline on the map
//           _polylines.add(Polyline(
//             polylineId: PolylineId("route"),
//             points: polylineCoordinates,
//             color: Colors.blue,
//             width: 5,
//           ));
//
//           // Get the distance (in meters) from the response
//           int distanceInMeters = data['routes'][0]['legs'][0]['distance'];
//
//           // Convert to kilometers for better readability
//           double distanceInKm = distanceInMeters / 1000;
//
//           // Update the distance state
//           setState(() {
//             _distance = distanceInKm;
//           });
//
//           // Move map camera to show both markers and the route
//           _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
//             LatLngBounds(
//               southwest: LatLng(
//                 sourceLat < destLat ? sourceLat : destLat,
//                 sourceLng < destLng ? sourceLng : destLng,
//               ),
//               northeast: LatLng(
//                 sourceLat > destLat ? sourceLat : destLat,
//                 sourceLng > destLng ? sourceLng : destLng,
//               ),
//             ),
//             50,
//           ));
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("No route found.")),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch route.")),
//         );
//       }
//
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Invalid input format.")),
//       );
//     }
//   }
//
// // Helper function to decode polyline
//   List<LatLng> _decodePolyline(String polyline) {
//     List<LatLng> polylineCoordinates = [];
//     int index = 0;
//     int len = polyline.length;
//     int lat = 0;
//     int lng = 0;
//
//     while (index < len) {
//       int b;
//       int shift = 0;
//       int result = 0;
//       do {
//         b = polyline.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dLat = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dLat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = polyline.codeUnitAt(index) - 63;
//         index++;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dLng = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dLng;
//
//       polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//
//     return polylineCoordinates;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Find Medical Location")),
//       body: _currentLocation == null
//           ? Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentLocation ?? LatLng(12.9716, 77.5946),
//               zoom: 10,
//             ),
//             markers: _markers,
//             polylines: _polylines,
//             onMapCreated: (GoogleMapController controller) {
//               _mapController = controller;
//               if (_currentLocation != null) {
//                 _mapController?.animateCamera(
//                     CameraUpdate.newLatLng(_currentLocation!));
//               }
//             },
//           ),
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Column(
//               children: [
//                 TextField(
//                   controller: sourceController,
//                   decoration: InputDecoration(
//                     hintText: "Source (lat,lng)",
//                     hintStyle: TextStyle(color: Colors.black),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.text,
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: destinationController,
//                   decoration: InputDecoration(
//                     hintText: "Destination (lat,lng)",
//                     hintStyle: TextStyle(color: Colors.black),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.text,
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _findRoute,
//                   child: Text("Show Route"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 100,
//             left: 100,
//             child: Container(
//               height: 50,
//               width: 200,
//               decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(40)
//               ),
//
//               child: Center(
//                 child: _distance==0
//                 ?Text("No route selected"):Text(
//                   "Distance: ${_distance.toStringAsFixed(2)} km",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapRouteApp extends StatefulWidget {
  @override
  _MapRouteAppState createState() => _MapRouteAppState();
}

class _MapRouteAppState extends State<MapRouteApp> {
  GoogleMapController? _mapController;
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  double _distance = 0.0;
  final String googleApiKey = "AIzaSyCQuTFjc2DXPqzXOl2JWGXQxSaYiBXdfrE"; // Your Google API key

  @override
  void initState() {
    super.initState();
    // Set default source and destination
    sourceController.text = "Panruti";
    destinationController.text = "Cuddalore";
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: MarkerId("current"),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: "Your Location"),
        ));
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is required")),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location permission in settings")),
      );
      openAppSettings();
    }
  }

  Future<LatLng?> _getCoordinatesFromPlace(String place) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(place)}&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not find location: $place")),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch coordinates for $place")),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching coordinates: $e")),
      );
      return null;
    }
  }

  void _findRoute() async {
    String source = sourceController.text.trim();
    String destination = destinationController.text.trim();

    if (source.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both source and destination")),
      );
      return;
    }

    try {
      // Convert place names to coordinates
      LatLng? sourcePosition = await _getCoordinatesFromPlace(source);
      LatLng? destinationPosition = await _getCoordinatesFromPlace(destination);

      if (sourcePosition == null || destinationPosition == null) {
        return; // Exit if coordinates could not be fetched
      }

      // Clear previous markers and polylines
      _markers.clear();
      _polylines.clear();

      // Add markers for source and destination
      _markers.add(Marker(
        markerId: MarkerId("source"),
        position: sourcePosition,
        infoWindow: InfoWindow(title: source),
      ));
      _markers.add(Marker(
        markerId: MarkerId("destination"),
        position: destinationPosition,
        infoWindow: InfoWindow(title: destination),
      ));

      // Use OSRM free public API for routing
      String url =
          "http://router.project-osrm.org/route/v1/driving/${sourcePosition.longitude},${sourcePosition.latitude};${destinationPosition.longitude},${destinationPosition.latitude}?overview=full&geometries=polyline";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['routes'].isNotEmpty) {
          List<LatLng> polylineCoordinates = [];

          // Extract polyline points
          var geometry = data['routes'][0]['geometry'];
          polylineCoordinates.addAll(_decodePolyline(geometry));

          // Add the polyline on the map
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));

          // Get the distance (in meters)
          int distanceInMeters = data['routes'][0]['legs'][0]['distance'];
          double distanceInKm = distanceInMeters / 1000;

          // Update the distance state
          setState(() {
            _distance = distanceInKm;
          });

          // Move map camera to show both markers and the route
          _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                sourcePosition.latitude < destinationPosition.latitude
                    ? sourcePosition.latitude
                    : destinationPosition.latitude,
                sourcePosition.longitude < destinationPosition.longitude
                    ? sourcePosition.longitude
                    : destinationPosition.longitude,
              ),
              northeast: LatLng(
                sourcePosition.latitude > destinationPosition.latitude
                    ? sourcePosition.latitude
                    : destinationPosition.latitude,
                sourcePosition.longitude > destinationPosition.longitude
                    ? sourcePosition.longitude
                    : destinationPosition.longitude,
              ),
            ),
            50,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No route found.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch route.")),
        );
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Medical Location")),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(12.9716, 77.5946),
              zoom: 10,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                _mapController?.animateCamera(
                    CameraUpdate.newLatLng(_currentLocation!));
              }
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    hintText: "Enter source (e.g., Panruti)",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    hintText: "Enter destination (e.g., Cuddalore)",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _findRoute,
                  child: Text("Show Route"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            left: 100,
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: _distance == 0
                    ? Text("No route selected")
                    : Text(
                  "Distance: ${_distance.toStringAsFixed(2)} km",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}