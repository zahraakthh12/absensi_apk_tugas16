import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';

class CheckInPage extends StatelessWidget {
  final Position? position;

  const CheckInPage({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = DateFormat("yyyy-MM-dd").format(now);
    final time = DateFormat("HH:mm").format(now);

    return Scaffold(
      appBar: AppBar(title: const Text("Check In")),
      body: position == null
          ? const Center(child: Text("Lokasi belum tersedia"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tanggal: $date"),
                  Text("Jam: $time"),
                  Text(
                    "Lokasi: ${position!.latitude}, ${position!.longitude}",
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await AbsensiAPI.checkIn(
                          attendanceDate: date,
                          time: time,
                          lat: position!.latitude,
                          lng: position!.longitude,
                          address: "Lokasi Pengguna",
                        );

                        Fluttertoast.showToast(
                            msg: "Check In Berhasil",
                            backgroundColor: Colors.green);

                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    child: const Text("Konfirmasi Check In"),
                  )
                ],
              ),
            ),
    );
  }
}
