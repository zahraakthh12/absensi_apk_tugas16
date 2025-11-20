import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';

/// =================================================================
///   PAGE UTAMA — PILIH ABSENSI (Check In / Check Out)
//  Soft Pastel UI ✔ Clean ✔ Minimalist ✔ Modern
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Kehadiran",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Silakan pilih jenis absensi:",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 22),

            // ========================= PASTEL CHECK IN BUTTON =========================
            _pastelButton(
              context: context,
              label: "Check In",
              subtitle: "Absen saat mulai",
              icon: Icons.login_rounded,
              colors: const [
                Color.fromARGB(255, 97, 146, 115),
                Color.fromARGB(255, 97, 146, 115),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceDetailPage(isCheckIn: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ========================= PASTEL CHECK OUT BUTTON =========================
            _pastelButton(
              context: context,
              label: "Check Out",
              subtitle: "Absen saat selesai",
              icon: Icons.logout_rounded,
              colors: const [
                Color.fromARGB(255, 173, 129, 129),
                Color.fromARGB(255, 173, 129, 129),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AttendanceDetailPage(isCheckIn: false),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ========================= PASTEL IZIN BUTTON =========================
            _pastelButton(
              context: context,
              label: "Ajukan Izin",
              subtitle: "Tidak bisa hadir? Ajukan izin",
              icon: Icons.event_busy_rounded,
              colors: const [
                Color.fromARGB(255, 153, 169, 199),
                Color.fromARGB(255, 180, 188, 204),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IzinPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ========================= PASTEL BUTTON WIDGET =========================
  Widget _pastelButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(icon, color: colors.first, size: 22),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final bool isCheckIn;

  const AttendanceDetailPage({super.key, required this.isCheckIn});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage>
    with SingleTickerProviderStateMixin {
  Position? position;
  String address = "Mengambil lokasi…";
  File? imageFile;
  bool loading = false;
  DataAttend? todayData;

  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    await Future.wait([_getLocation(), _loadTodayAttendance()]);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// ======================= GET LOCATION =======================
  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> place = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      final p = place.first;

      setState(() {
        address =
            "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
      });
    } catch (_) {}
  }

  /// ======================= LOAD TODAY ATTENDANCE =======================
  Future<void> _loadTodayAttendance() async {
    try {
      final history = await AbsensiAPI.getHistory();
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

      final match = history.where((e) => e.attendanceDate == today);
      if (match.isNotEmpty) todayData = match.first;
    } catch (_) {}

    setState(() {});
  }

  /// ======================= PICK IMAGE =======================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() => imageFile = File(img.path));
    }
  }

  /// ======================= SUBMIT =======================
  Future<void> _submitAttendance() async {
    if (position == null) {
      Fluttertoast.showToast(msg: "Lokasi belum ditemukan");
      return;
    }
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Ambil foto terlebih dahulu");
      return;
    }

    setState(() => loading = true);

    final now = DateTime.now();

    try {
      if (widget.isCheckIn) {
        await AbsensiAPI.checkIn(
          attendanceDate: DateFormat("yyyy-MM-dd").format(now),
          time: DateFormat("HH:mm").format(now),
          lat: position!.latitude,
          lng: position!.longitude,
          address: address,
        );
      } else {
        await AbsensiAPI.checkOut(
          attendanceDate: DateFormat("yyyy-MM-dd").format(now),
          time: DateFormat("HH:mm").format(now),
          lat: position!.latitude,
          lng: position!.longitude,
          address: address,
        );
      }

      Fluttertoast.showToast(
        msg: widget.isCheckIn ? "Check-In berhasil!" : "Check-Out berhasil!",
      );
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loading = false);
  }

  /// ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? "Absen Masuk" : "Absen Pulang";

    final mainColor = widget.isCheckIn
        ? const Color.fromARGB(255, 97, 146, 115) // pastel green
        : const Color.fromARGB(255, 173, 129, 129); // pastel red

    final btnSubmitColor = mainColor;

    final hasCheckIn = (todayData?.checkInTime ?? "").isNotEmpty;
    final hasCheckOut = (todayData?.checkOutTime ?? "").isNotEmpty;

    String statusText = widget.isCheckIn
        ? (hasCheckIn ? "Sudah Check In" : "Belum Check In")
        : (hasCheckOut ? "Sudah Check Out" : "Belum Check Out");

    final now = DateTime.now();
    final dayName = DateFormat("EEEE", "id_ID").format(now);
    final dateFormat = DateFormat("dd-MMM-yy", "id_ID").format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ====================== GOOGLE MAP ======================
                      SizedBox(
                        height: 280,
                        child: position == null
                            ? const Center(child: CircularProgressIndicator())
                            : GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    position!.latitude,
                                    position!.longitude,
                                  ),
                                  zoom: 16,
                                ),
                                myLocationEnabled: true,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                              ),
                      ),

                      // ================= WHITE CARD =================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // STATUS
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ADDRESS
                            const Text(
                              "Alamat:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(address, style: const TextStyle(height: 1.4)),

                            const SizedBox(height: 20),

                            // ================= CARD TIME =================
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Waktu Kehadiran",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Tanggal & Hari
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dayName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          Text(
                                            dateFormat,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Check IN/OUT
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              const Text(
                                                "Check In",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                todayData?.checkInTime ??
                                                    "-- : --",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 25),
                                          Container(
                                            width: 1,
                                            height: 26,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(width: 25),
                                          Column(
                                            children: [
                                              const Text(
                                                "Check Out",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                todayData?.checkOutTime ??
                                                    "-- : --",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ================= PICK IMAGE =================
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFAED4FF),
                                      Color(0xFFCAE8FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        imageFile == null
                                            ? "Ambil Foto"
                                            : "Ulangi Foto",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (imageFile != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                "Foto sudah diambil ✔",
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ],

                            const SizedBox(height: 30),

                            // ================= SUBMIT BUTTON =================
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _submitAttendance,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnSubmitColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  widget.isCheckIn ? "Check In" : "Check Out",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController alasanC = TextEditingController();
  late AnimationController _anim;
  late Animation<double> _fade;

  final DateTime today = DateTime.now();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    alasanC.dispose();
    super.dispose();
  }

  // ======================================
  // SUBMIT IZIN
  // ======================================
  Future<void> _submitIzin() async {
    if (alasanC.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Isi alasan izin");
      return;
    }

    setState(() => loading = true);

    try {
      await AbsensiAPI.sendIzin(
        date: DateFormat("yyyy-MM-dd").format(today),
        alasan: alasanC.text.trim(),
      );

      Fluttertoast.showToast(msg: "Izin berhasil diajukan");
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal mengajukan izin");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tampilTanggal = DateFormat(
      "EEEE, dd MMMM yyyy",
      "id_ID",
    ).format(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: const Text("Ajukan Izin"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER CARD CANTIK (gradient + ilustrasi)
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 153, 169, 199),
                      Color(0xFFC8E4FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_busy_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Ajukan Izin Kehadiran\nHari Ini",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =====================================================
              // TANGGAL HARI INI (readonly, style premium)
              // =====================================================
              Text(
                "Tanggal",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tampilTanggal,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =====================================================
              // INPUT ALASAN IZIN
              // =====================================================
              Text(
                "Alasan Izin",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: alasanC,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Contoh: Tidak bisa hadir karena sakit",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // =====================================================
              // TOMBOL AJUKAN IZIN
              // =====================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 153, 169, 199),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Kirim Izin",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
