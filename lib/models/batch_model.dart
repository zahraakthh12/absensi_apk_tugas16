// To parse this JSON data, do
//
//     final batchModel = batchModelFromJson(jsonString);

import 'dart:convert';

BatchModel batchModelFromJson(String str) =>
    BatchModel.fromJson(json.decode(str));

String batchModelToJson(BatchModel data) => json.encode(data.toJson());

class BatchModel {
  String? message;
  List<BatchModelData>? data;

  BatchModel({this.message, this.data});

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<BatchModelData>.from(
            json["data"]!.map((x) => BatchModelData.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BatchModelData {
  int? id;
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  String? createdAt;
  String? updatedAt;
  List<Training>? trainings;

  BatchModelData({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.trainings,
  });

  factory BatchModelData.fromJson(Map<String, dynamic> json) => BatchModelData(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    trainings: json["trainings"] == null
        ? []
        : List<Training>.from(
            json["trainings"]!.map((x) => Training.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt,
    "updated_at": updatedAt,
    "trainings": trainings == null
        ? []
        : List<dynamic>.from(trainings!.map((x) => x.toJson())),
  };
}

class Training {
  int? id;
  String? title;
  Pivot? pivot;

  Training({this.id, this.title, this.pivot});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "pivot": pivot?.toJson(),
  };
}

class Pivot {
  String? trainingBatchId;
  String? trainingId;

  Pivot({this.trainingBatchId, this.trainingId});

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    trainingBatchId: json["training_batch_id"],
    trainingId: json["training_id"],
  );

  Map<String, dynamic> toJson() => {
    "training_batch_id": trainingBatchId,
    "training_id": trainingId,
  };
}