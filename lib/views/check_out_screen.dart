import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';

class CheckOutPage extends StatelessWidget {
  final Position? position;

  const CheckOutPage({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(now);
    final time = DateFormat("HH:mm").format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          "Check Out",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: position == null
          ? const Center(child: Text("Lokasi belum tersedia"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ===== HEADER CARD =====
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDDEBFF), Color(0xFFE8F0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 60,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Konfirmasi Check Out",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Pastikan Anda benar-benar selesai bekerja",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== INFO CARD =====
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoTile("Tanggal", date, Icons.calendar_today),
                        const Divider(),
                        infoTile("Waktu", time, Icons.access_time_filled),
                        const Divider(),
                        infoTile(
                          "Lokasi",
                          "${position!.latitude.toStringAsFixed(5)}, "
                              "${position!.longitude.toStringAsFixed(5)}",
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ===== BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await AbsensiAPI.checkOut(
                            attendanceDate: DateFormat(
                              "yyyy-MM-dd",
                            ).format(now),
                            time: time,
                            lat: position!.latitude,
                            lng: position!.longitude,
                            address: "Lokasi Pengguna",
                          );

                          Fluttertoast.showToast(
                            msg: "Check Out Berhasil",
                            backgroundColor: Colors.green,
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Konfirmasi Check Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget infoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 26),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
