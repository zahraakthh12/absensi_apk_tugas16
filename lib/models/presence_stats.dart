class PresenceStats {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  PresenceStats({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory PresenceStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PresenceStats(
      totalAbsen: (data['total_absen'] is int)
          ? data['total_absen'] as int
          : int.tryParse('${data['total_absen']}') ?? 0,
      totalMasuk: (data['total_masuk'] is int)
          ? data['total_masuk'] as int
          : int.tryParse('${data['total_masuk']}') ?? 0,
      totalIzin: (data['total_izin'] is int)
          ? data['total_izin'] as int
          : int.tryParse('${data['total_izin']}') ?? 0,
      sudahAbsenHariIni: data['sudah_absen_hari_ini'] == true,
    );
  }
}