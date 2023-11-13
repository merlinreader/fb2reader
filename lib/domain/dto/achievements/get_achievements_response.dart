import 'package:json_annotation/json_annotation.dart';
import 'package:merlin/components/achievement.dart';

part 'get_achievements_response.g.dart';

@JsonSerializable(explicitToJson: true)
class GetAchievementsResponseBody {
  final Achievement baby;
  final Achievement spell;
  final List<Achievement> wordModeAchievements;
  final List<Achievement> simpleModeAchievements;

  const GetAchievementsResponseBody(
      {required this.baby,
      required this.spell,
      required this.wordModeAchievements,
      required this.simpleModeAchievements});

  factory GetAchievementsResponseBody.fromJson(Map<String, dynamic> json) =>
      _$GetAchievementsResponseBodyFromJson(json);
  Map<String, dynamic> toJson() => _$GetAchievementsResponseBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetAchievementsResponse {
  final GetAchievementsResponseBody achievements;

  const GetAchievementsResponse({required this.achievements});

  factory GetAchievementsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAchievementsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetAchievementsResponseToJson(this);
}
