import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';

class AbsensiAPI {
  static const baseUrl = "https://absensib1.mobileprojp.com/api";

  static Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _put(
      String endpoint, Map<String, dynamic> body) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _delete(String endpoint) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  // ABSENSI

  static Future<dynamic> checkIn({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post("/absen-check-in", {
      "attendance_date": attendanceDate,
      "check_in": time,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
      "status": "masuk"
    });
  }

  static Future<dynamic> checkOut({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) {
    return _post("/absen-check-out", {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat,$lng"
    });
  }

  static Future<dynamic> izin({
    required String date,
    required String alasan,
  }) {
    return _post("/absen-izin", {
      "date": date,
      "alasan_izin": alasan,
    });
  }

  static Future<dynamic> getHistory() {
    return _get("/history-absen");
  }

  static Future<dynamic> deleteAbsen(int id) {
    return _delete("/delete-absen?id=$id");
  }

  // PROFILE

  static Future<dynamic> getProfile() {
    return _get("/profile");
  }

  static Future<dynamic> editProfile({
    required String name,
    required String email,
  }) {
    return _put("/edit-profile", {
      "name": name,
      "email": email,
    });
  }
}
