class DataAttend {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? alasanIzin;

  DataAttend({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.alasanIzin,
  });

  factory DataAttend.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return DataAttend(
      id: json["id"],
      attendanceDate: json["attendance_date"],
      checkInTime: json["check_in_time"],
      checkOutTime: json["check_out_time"],
      checkInLat: parseDouble(json["check_in_lat"]),
      checkInLng: parseDouble(json["check_in_lng"]),
      checkOutLat: parseDouble(json["check_out_lat"]),
      checkOutLng: parseDouble(json["check_out_lng"]),
      checkInAddress: json["check_in_address"],
      checkOutAddress: json["check_out_address"],
      checkInLocation: json["check_in_location"],
      checkOutLocation: json["check_out_location"],
      status: json["status"] ?? "",
      alasanIzin: json["alasan_izin"],
    );
  }
}
