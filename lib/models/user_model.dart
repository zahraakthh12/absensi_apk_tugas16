import 'package:absensi_apk_tugas16/constant/url_helper.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePhoto; // full url or path
  final int? batchId;
  final int? trainingId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.batchId,
    this.trainingId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawPhoto = json["profile_photo"]?.toString();
    final photoUrl = UrlHelper.buildProfileUrl(rawPhoto);
    print(' poto be $photoUrl');
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePhoto: photoUrl.isEmpty ? null : photoUrl,
      batchId: json['batch_id'] != null
          ? int.tryParse(json['batch_id'].toString())
          : null,
      trainingId: json['training_id'] != null
          ? int.tryParse(json['training_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profile_photo': profilePhoto,
    'batch_id': batchId,
    'training_id': trainingId,
  };
}