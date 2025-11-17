import 'dart:convert';

AttendanceModel attendanceModelFromJson(String str) =>
    AttendanceModel.fromJson(json.decode(str));

class AttendanceModel {
  String? message;
  AttendanceData? data;

  AttendanceModel({this.message, this.data});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        message: json["message"],
        data: json["data"] == null
            ? null
            : AttendanceData.fromJson(json["data"]),
      );
}

class AttendanceData {
  int? id;
  String? attendanceDate;
  String? checkIn;
  String? checkOut;
  double? lat;
  double? lng;
  String? address;
  String? status;

  AttendanceData({
    this.id,
    this.attendanceDate,
    this.checkIn,
    this.checkOut,
    this.lat,
    this.lng,
    this.address,
    this.status,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) =>
      AttendanceData(
        id: json["id"],
        attendanceDate: json["attendance_date"],
        checkIn: json["check_in"],
        checkOut: json["check_out"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
        address: json["address"],
        status: json["status"],
      );
}
