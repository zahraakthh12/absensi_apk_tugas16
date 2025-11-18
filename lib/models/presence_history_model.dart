// lib/features/presence/models/presence_history_model.dart

import 'dart:convert';

/// Model root
class PresenceHistoryModel {
  final String? message;
  final List<Presence> data;

  PresenceHistoryModel({
    this.message,
    required this.data,
  });

  factory PresenceHistoryModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    return PresenceHistoryModel(
      message: json['message'] as String?,
      data: list.map((e) => Presence.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
      };

  factory PresenceHistoryModel.fromRawJson(String str) =>
      PresenceHistoryModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// Single presence record
class Presence {
  final int id;
  final DateTime? attendanceDate;
  final String? checkInTime; // keep as string (ex: "08:10" or "08:10:00")
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInLocation; // raw string "-6.123456,106.123456"
  final String? checkOutLocation;
  final PresenceStatus status;
  final String? alasanIzin;

  Presence({
    required this.id,
    this.attendanceDate,
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
    this.status = PresenceStatus.masuk,
    this.alasanIzin,
  });

  factory Presence.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s);
    }

    DateTime? _parseDate(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    final statusStr = (json['status'] as String?) ?? '';
    return Presence(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      attendanceDate: _parseDate(json['attendance_date']?.toString()),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
      checkInLat: _toDouble(json['check_in_lat']),
      checkInLng: _toDouble(json['check_in_lng']),
      checkOutLat: _toDouble(json['check_out_lat']),
      checkOutLng: _toDouble(json['check_out_lng']),
      checkInAddress: json['check_in_address']?.toString(),
      checkOutAddress: json['check_out_address']?.toString(),
      checkInLocation: json['check_in_location']?.toString(),
      checkOutLocation: json['check_out_location']?.toString(),
      status: PresenceStatus.fromString(statusStr),
      alasanIzin: json['alasan_izin']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attendance_date': attendanceDate?.toIso8601String(),
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'check_in_lat': checkInLat,
        'check_in_lng': checkInLng,
        'check_out_lat': checkOutLat,
        'check_out_lng': checkOutLng,
        'check_in_address': checkInAddress,
        'check_out_address': checkOutAddress,
        'check_in_location': checkInLocation,
        'check_out_location': checkOutLocation,
        'status': status.value,
        'alasan_izin': alasanIzin,
      };

  /// Helper: formatted date (e.g. 20 Jul 2025)
  String formattedDate({String pattern = 'yyyy-MM-dd'}) {
    if (attendanceDate == null) return '-';
    // simple formatting without intl to avoid dependency; return yyyy-MM-dd or custom manual format
    final d = attendanceDate!;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Helper: return display time range, preferring checkInTime string (normalized to HH:mm if possible)
  String timeRangeDisplay() {
    final inStr = _normalizeTimeToHHmm(checkInTime);
    final outStr = (checkOutTime == null || checkOutTime!.isEmpty) ? '-' : checkOutTime!;
    final inDisplay = (inStr ?? '-') ;
    return '$inDisplay - $outStr';
  }

  /// Normalize input like "08:10:00" -> "08:10", "08:10" -> "08:10"
  String? _normalizeTimeToHHmm(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    final regex = RegExp(r'(\d{2}:\d{2})');
    final m = regex.firstMatch(s);
    if (m != null) return m.group(1);
    if (s.length >= 5) return s.substring(0, 5);
    return s;
  }

  /// Parse checkInLocation into a simple LatLng structure (or null)
  LatLngSimple? get checkInLatLng => LatLngSimple.fromString(checkInLocation);

  LatLngSimple? get checkOutLatLng => LatLngSimple.fromString(checkOutLocation);
}

/// Simple lat/lng holder (no external dependency)
class LatLngSimple {
  final double lat;
  final double lng;
  LatLngSimple(this.lat, this.lng);

  @override
  String toString() => '$lat,$lng';

  static LatLngSimple? fromString(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim();
    if (clean.isEmpty) return null;
    final parts = clean.split(',');
    if (parts.length < 2) return null;
    final a = double.tryParse(parts[0].trim());
    final b = double.tryParse(parts[1].trim());
    if (a == null || b == null) return null;
    return LatLngSimple(a, b);
  }
}

/// Presence status helper (masuk / izin / unknown)
class PresenceStatus {
  final String value;
  const PresenceStatus._(this.value);

  static const masuk = PresenceStatus._('masuk');
  static const izin = PresenceStatus._('izin');
  static const unknown = PresenceStatus._('unknown');

  static PresenceStatus fromString(String? s) {
    final val = (s ?? '').toLowerCase();
    if (val == 'masuk') return PresenceStatus.masuk;
    if (val == 'izin') return PresenceStatus.izin;
    return PresenceStatus.unknown;
  }

  String get label {
    switch (this.value) {
      case 'masuk':
        return 'Masuk';
      case 'izin':
        return 'Izin';
      default:
        return value;
    }
  }
}