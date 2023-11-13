import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final String description;
  @JsonKey(fromJson: _parseDateFromString)
  final DateTime? date;
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

  static DateTime? _parseDateFromString(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return null;
    return DateTime.tryParse(rawDate);
  }
}
