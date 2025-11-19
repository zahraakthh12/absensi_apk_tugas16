import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
import 'package:absensi_apk_tugas16/models/profile_model.dart';
import 'package:absensi_apk_tugas16/models/attendance_model.dart';
import 'package:absensi_apk_tugas16/constant/endpoint.dart';

class AbsensiAPI {
  // HEADER TOKEN
  static Future<Map<String, String>> _headers() async {
    final token = await PreferenceHandler.getToken();

    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  // GET METHOD
  static Future<dynamic> _get(String url) async {
    final headers = await _headers();

    final res = await http.get(Uri.parse(url), headers: headers);

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception(_errorMsg(res.body));
  }

  // POST METHOD
  static Future<dynamic> _post(String url, Map<String, dynamic> body) async {
    final headers = await _headers();

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }

    throw Exception(_errorMsg(res.body));
  }

  static Future<dynamic> _put(String url, Map<String, dynamic> body) async {
    final headers = await _headers();

    final res = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }

    throw Exception(_errorMsg(res.body));
  }

  // DELETE METHOD
  static Future<dynamic> _delete(String url) async {
    final headers = await _headers();

    final res = await http.delete(Uri.parse(url), headers: headers);

    if (res.statusCode == 200) return jsonDecode(res.body);

    throw Exception(_errorMsg(res.body));
  }

  // Parse error message
  static String _errorMsg(String body) {
    try {
      return jsonDecode(body)["message"] ?? "Terjadi kesalahan";
    } catch (_) {
      return "Terjadi kesalahan";
    }
  }

  // GET PROFILE
  static Future<ProfileModel> getProfile() async {
    final data = await _get(Endpoint.profile);
    return ProfileModel.fromJson(data);
  }

  // EDIT PROFILE
  static Future<dynamic> editProfile({
    required String name,
    // required String email,
  }) async {
    return _put(Endpoint.profile, {"name": name});
  }

  // UPLOAD PROFILE PHOTO
  static Future<void> updateProfilePhoto({
    required String name,
    required String email,
    File? photo,
  }) async {
    final token = await PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.updateProfilePhoto);

    var request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $token";
    request.fields["name"] = name;
    request.fields["email"] = email;

    if (photo != null) {
      request.files.add(
        await http.MultipartFile.fromPath("profile_photo", photo.path),
      );
    }

    final res = await request.send();

    if (res.statusCode != 200) {
      throw Exception("Gagal mengupdate foto profil");
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
    final res = await _post(Endpoint.checkIn, {
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
    final res = await _post(Endpoint.checkOut, {
      "attendance_date": attendanceDate,
      "check_out": time,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
    });

    return DataAttend.fromJson(res["data"]);
  }

  // HISTORY
  static Future<List<DataAttend>> getHistory() async {
    final data = await _get(Endpoint.histroyAttend);

    final List list = data["data"] ?? [];

    return list.map((e) => DataAttend.fromJson(e)).toList();
  }

  // TODAY PRESENCE (opsional)
  static Future<dynamic> getTodayPresence() async {
    return _get(Endpoint.todayPresence);
  }

  // PRESENCE STATS
  static Future<dynamic> getPresenceStats() async {
    return _get(Endpoint.presenceStats);
  }

  // DELETE ABSEN
  static Future<void> deleteAbsenById(int id) async {
    await _delete("${Endpoint.deleteAbsen}/$id");
  }

  static Future<void> sendIzin({
    required String date,
    required String alasan,
  }) async {
    final token = await PreferenceHandler.getToken();

    final url = Uri.parse("${Endpoint.baseUrl}/izin");

    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {"date": date, "alasan_izin": alasan},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal mengirim izin");
    }
  }
}
