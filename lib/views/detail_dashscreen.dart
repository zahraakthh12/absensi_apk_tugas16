import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DetailLocationPage extends StatefulWidget {
  final Position position;

  const DetailLocationPage({super.key, required this.position});

  @override
  State<DetailLocationPage> createState() => _DetailLocationPageState();
}

class _DetailLocationPageState extends State<DetailLocationPage> {
  late GoogleMapController mapController;
  late Position currentPos;
  String fullAddress = "Mengambil alamat...";

  @override
  void initState() {
    super.initState();
    currentPos = widget.position;
    getAddressFromCoordinates();
  }

  // Ambil alamat lengkap dari latitude-longitude
  Future<void> getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPos.latitude,
        currentPos.longitude,
      );

      final p = placemarks.first;

      setState(() {
        fullAddress =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.subAdministrativeArea}, "
            "${p.administrativeArea} ${p.postalCode}";
      });
    } catch (e) {
      setState(() => fullAddress = "Gagal mengambil alamat");
    }
  }

  // Refresh lokasi
  Future<void> refreshLocation() async {
    Position updated = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() => currentPos = updated);

    await getAddressFromCoordinates();

    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(updated.latitude, updated.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng target =
        LatLng(currentPos.latitude, currentPos.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Lokasi"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
        onPressed: refreshLocation,
      ),
      body: Stack(
        children: [
          // MAPS
          GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (c) => mapController = c,
            markers: {
              Marker(
                markerId: const MarkerId("current"),
                position: target,
                infoWindow: const InfoWindow(title: "Lokasi Anda"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
            },
          ),

          // ALAMAT CARD
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.red, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fullAddress,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
