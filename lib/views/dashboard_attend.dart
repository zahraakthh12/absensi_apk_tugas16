import 'dart:ui'; // untuk ImageFilter blur

import 'package:absensi_apk_tugas16/models/attendance_model.dart';
import 'package:absensi_apk_tugas16/models/presence_stats.dart';
import 'package:absensi_apk_tugas16/models/profile_model.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/views/detail_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ANIMASI
  late AnimationController _slideCtrl;
  late AnimationController _fadeCtrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  // DATA USER
  String username = "";
  String? userPhoto;
  String fullAddress = "Mengambil lokasi…";

  // DATA ABSENSI
  Position? currentPosition;
  DataAttend? todayData;
  PresenceStats? stats;
  List<DataAttend> historyList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ANIMASI SLIDE
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // ANIMASI FADE
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _loadAllData();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // GREETING DINAMIS
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return "Selamat Pagi!";
    if (hour >= 11 && hour < 15) return "Selamat Siang!";
    if (hour >= 15 && hour < 18) return "Selamat Sore!";
    return "Selamat Malam!";
  }

  // ========================= LOAD SEMUA DATA =========================
  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    ProfileModel? profile;
    dynamic statsRes;
    List<DataAttend> history = [];

    await Future.wait([
      AbsensiAPI.getProfile().then((p) => profile = p),
      AbsensiAPI.getPresenceStats().then((s) => statsRes = s),
      AbsensiAPI.getHistory().then((h) => history = h),
      _getLocationInternal(),
    ]);

    // USER
    username = profile?.data?.name ?? "Pengguna";
    userPhoto = profile?.data?.profilePhoto ?? "";

    await PreferenceHandler.saveName(username);
    await PreferenceHandler.savePhoto(userPhoto ?? "");

    // STATS
    if (statsRes is Map<String, dynamic>) {
      stats = PresenceStats.fromJson(statsRes);
    } else {
      stats = null;
    }

    // HISTORY + TODAY
    history.sort(
      (a, b) => (b.attendanceDate ?? '').compareTo(a.attendanceDate ?? ''),
    );
    historyList = history;

    final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
    todayData = null;
    for (final h in historyList) {
      if (h.attendanceDate == todayStr) {
        todayData = h;
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // jalankan animasi setelah data siap
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  // dipakai setelah delete absen
  Future<void> _refreshAfterChange() async {
    setState(() => isLoading = true);

    dynamic statsRes;
    List<DataAttend> history = [];

    await Future.wait([
      AbsensiAPI.getPresenceStats().then((s) => statsRes = s),
      AbsensiAPI.getHistory().then((h) => history = h),
    ]);

    if (statsRes is Map<String, dynamic>) {
      stats = PresenceStats.fromJson(statsRes);
    }

    history.sort(
      (a, b) => (b.attendanceDate ?? '').compareTo(a.attendanceDate ?? ''),
    );
    historyList = history;

    final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
    todayData = null;
    for (final h in historyList) {
      if (h.attendanceDate == todayStr) {
        todayData = h;
        break;
      }
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ========================= LOCATION =========================
  Future<void> _getLocationInternal() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

  // ========================= DELETE ABSENSI =========================
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

  Future<void> deleteAttendanceById(int id) async {
    try {
      await AbsensiAPI.deleteAbsenById(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Absensi berhasil dihapus")));
      await _refreshAfterChange();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus absensi")));
    }
  }

  // ========================= GLASS CARD HELPER =========================
  Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.6),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ========================= HISTORY CARD =========================
  Widget historyCard(DataAttend p) {
    final checkIn = p.checkInTime ?? "-";
    final checkOut = p.checkOutTime ?? "-";

    // TANGGAL
    final dateRaw = p.attendanceDate ?? '';
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

    // STATUS IZIN
    final bool isIzin =
        (p.status?.toLowerCase() == "izin") ||
        ((p.checkInTime == null || p.checkInTime!.isEmpty) &&
            (p.checkOutTime == null || p.checkOutTime!.isEmpty));

    // ========================= LOKASI =========================
    final checkInLocation = p.checkInAddress?.trim().isNotEmpty == true
        ? p.checkInAddress!
        : "-";

    final checkOutLocation = p.checkOutAddress?.trim().isNotEmpty == true
        ? p.checkOutAddress!
        : "-";

    return glassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // BADGE IZIN
                  if (isIzin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Izin",
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              // DELETE
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  final confirm = await showDeleteDialog();
                  if (confirm == true && p.id != null) {
                    await deleteAttendanceById(p.id!);
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
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            dateFormatted,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),

          const SizedBox(height: 14),

          // ========================= LOKASI CHECK IN =========================
          Row(
            children: [
              Icon(
                Icons.pin_drop_rounded,
                size: 18,
                color: isIzin ? Colors.orange : Colors.blue.shade700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Lokasi Check In:\n$checkInLocation",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ========================= LOKASI CHECK OUT =========================
          Row(
            children: [
              Icon(
                Icons.exit_to_app_rounded,
                size: 18,
                color: isIzin ? Colors.orange : Colors.blue.shade700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Lokasi Check Out:\n$checkOutLocation",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: Colors.blue.shade50),
          const SizedBox(height: 14),

          // JAM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIzin ? "-" : checkIn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Container(width: 1, height: 22, color: Colors.black12),

              Column(
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIzin ? "-" : checkOut,
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

  // ========================= BUILD UI =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background gradient soft blue
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F2FF), Color(0xFFE9F2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(),
                  ),
                )
              : FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileHeader(),
                          statsCard(),
                          attendanceCard(),
                          mapCard(),
                          historySection(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // ========================= PROFILE HEADER =========================
  Widget profileHeader() {
    return glassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // avatar dengan ring gradient
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4F8CFF), Color(0xFF73B2FF)],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: (userPhoto != null && userPhoto!.isNotEmpty)
                  ? NetworkImage(userPhoto!)
                  : null,
              child: (userPhoto == null || userPhoto!.isEmpty)
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 19,
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

  // ========================= STATS CARD =========================
  Widget statsCard() {
    if (stats == null) {
      return glassCard(
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Memuat statistik..."),
          ],
        ),
      );
    }

    return glassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistik Absensi",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statBlock(
                label: "Total Absen",
                value: stats!.totalAbsen,
                icon: Icons.fact_check,
                showRightBorder: true,
              ),
              _statBlock(
                label: "Total Masuk",
                value: stats!.totalMasuk,
                icon: Icons.login_rounded,
                showRightBorder: true,
              ),
              _statBlock(
                label: "Total Izin",
                value: stats!.totalIzin,
                icon: Icons.event_busy_rounded,
                showRightBorder: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBlock({
    required String label,
    required int value,
    required IconData icon,
    required bool showRightBorder,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: showRightBorder
              ? const Border(
                  right: BorderSide(color: Color(0xFFE3ECFF), width: 1),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade300, width: 1.4),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 18, color: Colors.blue.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= ATTENDANCE CARD =========================
  Widget attendanceCard() {
    final todayReadable = DateFormat(
      "EEEE, dd MMMM yyyy",
      "id_ID",
    ).format(DateTime.now());

    return glassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Absensi Hari Ini",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          // === TANGGAL ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  todayReadable,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // === LOKASI ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_pin, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fullAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.blue.shade50),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayData?.checkInTime ?? "-- : --",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              Container(height: 34, width: 1.2, color: Colors.blue.shade50),
              Column(
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayData?.checkOutTime ?? "-- : --",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
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

  // ========================= MAP CARD =========================
  Widget mapCard() {
    return glassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Your Location",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
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
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Buka Maps",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================= HISTORY SECTION =========================
  Widget historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Absensi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
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
                      onPressed: () {
                        // TODO: halaman riwayat penuh kalau mau
                      },
                      child: const Text(
                        "Lihat Semua Riwayat",
                        style: TextStyle(color: Colors.blue),
                      ),
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
