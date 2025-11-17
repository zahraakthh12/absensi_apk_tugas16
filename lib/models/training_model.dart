// To parse this JSON data, do
//
//     final trainingModel = trainingModelFromJson(jsonString);

import 'dart:convert';

TrainingModel trainingModelFromJson(String str) =>
    TrainingModel.fromJson(json.decode(str));

String trainingModelToJson(TrainingModel data) => json.encode(data.toJson());

class TrainingModel {
  String? message;
  List<TrainingModelData>? data;

  TrainingModel({this.message, this.data});

  factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<TrainingModelData>.from(
            json["data"]!.map((x) => TrainingModelData.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TrainingModelData {
  int? id;
  String? title;

  TrainingModelData({this.id, this.title});

  factory TrainingModelData.fromJson(Map<String, dynamic> json) =>
      TrainingModelData(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}