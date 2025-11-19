import 'dart:async';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/views/detail_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  String username = "";
  String userId = "";
  String fullAddress = "Mengambil lokasi…";
  String? userPhoto;

  Position? currentPosition;
  DataAttend? todayData;
  List<DataAttend> historyList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    loadUser();
    getLocation();
    loadTodayAttendance();
    loadHistory();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // LOAD USER
  Future<void> loadUser() async {
    try {
      final profile = await AbsensiAPI.getProfile();

      username = profile.data?.name ?? "Pengguna";
      userId = profile.data?.id.toString() ?? "";
      userPhoto = profile.data?.profilePhoto ?? "";

      await PreferenceHandler.saveName(username);
      await PreferenceHandler.savePhoto(userPhoto ?? "");
    } catch (e) {
      username = "Pengguna";
    }

    setState(() {});
  }

  Future<void> deleteAttendanceById(int id) async {
    try {
      await AbsensiAPI.deleteAbsenById(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Absensi berhasil dihapus")));

      loadHistory(); // refresh
      loadTodayAttendance();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus absensi")));
    }
  }

  // LOAD HISTORY
  Future<void> loadHistory() async {
    try {
      final response = await AbsensiAPI.getHistory();

      // sort terbaru
      response.sort((a, b) => (b.attendanceDate).compareTo(a.attendanceDate));

      setState(() {
        historyList = response;
      });
    } catch (_) {}
  }

  // GET LOCATION
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

      fullAddress =
          "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
    } catch (_) {
      fullAddress = "Alamat tidak ditemukan";
    }
  }

  // DELETE ABSEN
  Future<bool?> showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Hapus Absensi?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus absensi ini? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ABSEN HARI INI
  Future<void> loadTodayAttendance() async {
    try {
      final history = await AbsensiAPI.getHistory();
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final match = history.where((e) => e.attendanceDate == today);
      todayData = match.isNotEmpty ? match.first : null;
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // FORMAT DATE
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // HISTORY CARD
  Widget historyCard(DataAttend p) {
    final checkIn = p.checkInTime ?? "-";
    final checkOut = p.checkOutTime ?? "-";

    final dateRaw = p.attendanceDate;
    DateTime? date;

    try {
      date = DateTime.parse(dateRaw);
    } catch (_) {}

    final dayName = date != null
        ? DateFormat("EEEE", "id_ID").format(date).capitalize()
        : "-";

    final dateFormatted = date != null
        ? DateFormat("dd-MMM-yy", "id_ID").format(date)
        : dateRaw;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== TOP BAR: HARI + DELETE BUTTON ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),

              // ===== DELETE BUTTON =====
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  final confirm = await showDeleteDialog();
                  if (confirm == true) {
                    if (p.id != null) {
                      await deleteAttendanceById(p.id);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ====== TANGGAL ======
          Text(
            dateFormatted,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),

          const SizedBox(height: 12),

          // ====== JAM CHECK IN & OUT ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // IN
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checkIn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Container(width: 1.4, height: 26, color: Colors.black12),

              // OUT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checkOut,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileHeader(),
                      const SizedBox(height: 22),
                      attendanceCard(),
                      const SizedBox(height: 22),
                      mapCard(),
                      const SizedBox(height: 22),
                      historySection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // PROFILE HEADER
  Widget profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F8CFF), Color(0xFF73B2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue.shade200,
            backgroundImage: (userPhoto != null && userPhoto!.isNotEmpty)
                ? NetworkImage(userPhoto!)
                : null,
            child: (userPhoto == null || userPhoto!.isEmpty)
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : "?",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // ====== TEXT BAGIAN KANAN (WAJIB EXPANDED BIAR GA OVERFLOW) ======
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo 👋",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                // NAMA USER — FIX OVERFLOW
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARD ABSENSI
  Widget attendanceCard() {
    final todayReadable = DateFormat(
      "EEEE, dd MMMM yyyy",
      "id_ID",
    ).format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6FA9FF), const Color(0xFF9FD0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Absensi",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                todayReadable,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Icon(Icons.location_pin, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fullAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Container(height: 1.2, color: Colors.white.withOpacity(0.35)),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayData?.checkInTime ?? "-- : --",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Container(
                height: 45,
                width: 1.6,
                color: Colors.white.withOpacity(0.6),
              ),

              Column(
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayData?.checkOutTime ?? "-- : --",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAP CARD
  Widget mapCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Location",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 190,
              child: currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomGesturesEnabled: false,
                    ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: currentPosition == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailLocationPage(position: currentPosition!),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Buka Maps",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HISTORY SECTION (IN DASHBOARD)
  Widget historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Riwayat Absensi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade900,
          ),
        ),

        const SizedBox(height: 14),

        historyList.isEmpty
            ? const Text(
                "Belum ada riwayat",
                style: TextStyle(color: Colors.black54),
              )
            : Column(
                children: [
                  ...historyList.take(5).map((e) => historyCard(e)),

                  if (historyList.length > 5)
                    TextButton(
                      onPressed: () {},
                      child: const Text("Lihat Semua Riwayat"),
                    ),
                ],
              ),
      ],
    );
  }
}

extension StringCasing on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
