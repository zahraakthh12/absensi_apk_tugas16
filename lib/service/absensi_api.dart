import 'dart:convert';
import 'dart:developer';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';
import 'package:http/http.dart' as http;
import 'package:absensi_apk_tugas16/models/user_model.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';

class AbsensiAPI {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // HEADER TOKEN
  static Future<Map<String, String>> _headers() async {
    final token = await PreferenceHandler.getToken();
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  // GET
  static Future<dynamic> _get(String endpoint) async {
    final headers = await _headers();
    final url = "$baseUrl$endpoint";

    final res = await http.get(Uri.parse(url), headers: headers);

    log("GET → $url");
    log("STATUS → ${res.statusCode}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  // POST
  static Future<dynamic> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final url = "$baseUrl$endpoint";

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    log("POST → $url");
    log("DATA → $body");
    log("STATUS → ${res.statusCode}");
    log("BODY → ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  // STATISTIK
  static Future<dynamic> getStat() {
    return _get('/absen/stats');
  }

  // PROFILE
  static Future<GetUserModel> getProfile() async {
    final token = await PreferenceHandler.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (res.statusCode == 200) {
      return GetUserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  // CHECK IN
  static Future<DataAttend> checkIn({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final res = await _post("/absen/check-in", {
      "attendance_date": attendanceDate,
      "check_in": time,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
    });

    return DataAttend.fromJson(res["data"]);
  }

  // CHECK OUT
  static Future<DataAttend> checkOut({
    required String attendanceDate,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final res = await _post("/absen/check-out", {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat,$lng",
    });

    return DataAttend.fromJson(res["data"]);
  }

  // HISTORY
  static Future<List<DataAttend>> getHistory() async {
    final data = await _get("/absen/history");
    final List list = data["data"] ?? [];

    return list.map((e) => DataAttend.fromJson(e)).toList();
  }

  // EDIT PROFILE
  static Future<dynamic> editProfile({
    required String name,
    required String email,
  }) async {
    return _post("/edit-profile", {"name": name, "email": email});
  }
}
