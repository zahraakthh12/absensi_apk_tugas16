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
@override
Widget build(BuildContext context) {
  final LatLng pos = LatLng(currentPos.latitude, currentPos.longitude);

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      elevation: 0,
      title: const Text("Lokasi Saat Ini"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    ),

    body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: pos, zoom: 16),
          myLocationEnabled: true,
          markers: {
            Marker(
              markerId: const MarkerId("loc"),
              position: pos,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          },
          onMapCreated: (c) => mapController = c,
        ),

        Positioned(
          left: 16, right: 16, bottom: 24,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fullAddress,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

}
