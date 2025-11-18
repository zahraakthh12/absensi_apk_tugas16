import 'dart:async';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';
import 'package:absensi_apk_tugas16/views/detail_dashscreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String username = "";
  Position? currentPosition;
  String fullAddress = "Mengambil lokasi…";

  DataAttend? todayData;

  bool isLoading = false;

  // Statistik API
  int totalMasuk = 0;
  int totalIzin = 0;
  int totalAbsen = 0;
  bool sudahAbsenHariIni = false;

  @override
  void initState() {
    super.initState();
    loadUser();
    getLocation();
    loadAttendanceData();
  }

  // ================= LOAD USER =================
  Future<void> loadUser() async {
    try {
      final saved = await PreferenceHandler.getName();
      if (saved != null && saved.isNotEmpty) {
        username = saved;
      } else {
        final profile = await AbsensiAPI.getProfile();
        username = profile.data?.name ?? "Pengguna";
        PreferenceHandler.saveName(username);
      }
    } catch (_) {
      username = "Pengguna";
    }
    setState(() {});
  }

  // ================= GET LOCATION + ADDRESS =================
  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await getAddressFromLatLng();
    setState(() {});
  }

  Future<void> getAddressFromLatLng() async {
    if (currentPosition == null) return;

    try {
      List<Placemark> place = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      final p = place.first;

      setState(() {
        fullAddress =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.subAdministrativeArea}, "
            "${p.administrativeArea} ${p.postalCode}";
      });
    } catch (e) {
      fullAddress = "Alamat tidak ditemukan";
    }
  }

  // ================= LOAD DATA HISTORY + STAT =================
  Future<void> loadAttendanceData() async {
    setState(() => isLoading = true);

    try {
      final history = await AbsensiAPI.getHistory();
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final match = history.where((e) => e.attendanceDate == today);

      todayData = match.isNotEmpty ? match.first : null;

      final stat = await AbsensiAPI.getStat();
      final data = stat["data"];

      totalMasuk = data["total_masuk"] ?? 0;
      totalIzin = data["total_izin"] ?? 0;
      totalAbsen = data["total_absen"] ?? 0;
      sudahAbsenHariIni = data["sudah_absen_hari_ini"] ?? false;
    } catch (e) {}

    setState(() => isLoading = false);
  }

  // ================= CHECK IN =================
  Future<void> checkIn() async {
    if (currentPosition == null) {
      Fluttertoast.showToast(msg: "Lokasi tidak ditemukan");
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();

      await AbsensiAPI.checkIn(
        attendanceDate: DateFormat("yyyy-MM-dd").format(now),
        time: DateFormat("HH:mm").format(now),
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
        address: fullAddress,
      );

      Fluttertoast.showToast(msg: "Absen Masuk Berhasil");
      await loadAttendanceData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => isLoading = false);
  }

  // ================= CHECK OUT =================
  Future<void> checkOut() async {
    if (currentPosition == null) {
      Fluttertoast.showToast(msg: "Lokasi tidak ditemukan");
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();

      await AbsensiAPI.checkOut(
        attendanceDate: DateFormat("yyyy-MM-dd").format(now),
        time: DateFormat("HH:mm").format(now),
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
        address: fullAddress,
      );

      Fluttertoast.showToast(msg: "Absen Pulang Berhasil");
      await loadAttendanceData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final todayReadable = DateFormat(
      "EEEE, dd MMMM yyyy",
      "id_ID",
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============= HEADER GRADIENT =============
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, $username 👋",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todayReadable,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ============= CARD LOKASI =============
                  InkWell(
                    onTap: currentPosition == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailLocationPage(
                                  position: currentPosition!,
                                ),
                              ),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fullAddress,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ============= STATISTIK CARD =============
                  const Text(
                    "Statistik Absensi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      statCard(
                        "Hadir",
                        totalMasuk,
                        Colors.green,
                        Icons.login_rounded,
                      ),
                      const SizedBox(width: 12),
                      statCard(
                        "Izin",
                        totalIzin,
                        Colors.orange,
                        Icons.warning_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      statCard(
                        "Total Absen",
                        totalAbsen,
                        Colors.blue,
                        Icons.calendar_today_rounded,
                      ),
                      const SizedBox(width: 12),
                      statCard(
                        "Hari Ini",
                        sudahAbsenHariIni ? 1 : 0,
                        Colors.purple,
                        Icons.check_circle_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ============= BUTTON CHECK IN/OUT =============
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => checkIn(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Absen Masuk",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => checkOut(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Absen Pulang",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ============= COMPONENT: STAT CARD =============
  Widget statCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
