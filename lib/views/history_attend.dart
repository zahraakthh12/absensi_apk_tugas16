import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';

class HistoryAttendScreen extends StatefulWidget {
  const HistoryAttendScreen({super.key});

  @override
  State<HistoryAttendScreen> createState() => _HistoryAttendScreenState();
}

class _HistoryAttendScreenState extends State<HistoryAttendScreen> {
  bool isLoading = true;
  List<DataAttend> historyList = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ================== LOAD HISTORY ==================
  Future<void> loadHistory() async {
    setState(() => isLoading = true);

    try {
      final response = await AbsensiAPI.getHistory();

      // Urutkan dari tanggal terbaru ke terlama
      response.sort((a, b) {
        final ad = a.attendanceDate ?? '';
        final bd = b.attendanceDate ?? '';
        return bd.compareTo(ad);
      });

      setState(() {
        historyList = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Format "yyyy-MM-dd" → "EEEE, dd MMMM yyyy" (Indonesia)
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // ================== CARD RIWAYAT ==================
  Widget historyCard(DataAttend p) {
    final checkIn = p.checkInTime ?? "-";
    final checkOut = p.checkOutTime ?? "-";

    final checkInLoc = p.checkInLocation ?? "-";
    final checkOutLoc = p.checkOutLocation ?? "-";

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================== TANGGAL ==================
          Text(
            formatDate(p.attendanceDate),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 10),

          // ================== MASUK ==================
          Row(
            children: [
              const Icon(Icons.login, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Masuk : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: Text(checkIn, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Lokasi Masuk : $checkInLoc",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ================== PULANG ==================
          Row(
            children: [
              const Icon(Icons.logout, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Pulang : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: Text(checkOut, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.blueGrey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Lokasi Pulang : $checkOutLoc",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),

          // ================== IZIN (OPSIONAL) ==================
          if (p.status == "izin" && (p.alasanIzin ?? "").isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.purple, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Izin: ${p.alasanIzin}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(
          "Riwayat Absensi",
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada riwayat absensi",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final p = historyList[index];
                  return historyCard(p);
                },
              ),
            ),
    );
  }
}
