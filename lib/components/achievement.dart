import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final String description;
  final String? date;
  final String picture;
  final bool isReceived;

  const Achievement({
    required this.description,
    this.date,
    required this.picture,
    required this.isReceived,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}
