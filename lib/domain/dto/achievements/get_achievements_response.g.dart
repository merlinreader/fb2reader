// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_achievements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAchievementsResponseBody _$GetAchievementsResponseBodyFromJson(
        Map<String, dynamic> json) =>
    GetAchievementsResponseBody(
      baby: Achievement.fromJson(json['baby'] as Map<String, dynamic>),
      spell: Achievement.fromJson(json['spell'] as Map<String, dynamic>),
      wordModeAchievements: (json['wordModeAchievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      simpleModeAchievements: (json['simpleModeAchievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAchievementsResponseBodyToJson(
        GetAchievementsResponseBody instance) =>
    <String, dynamic>{
      'baby': instance.baby.toJson(),
      'spell': instance.spell.toJson(),
      'wordModeAchievements':
          instance.wordModeAchievements.map((e) => e.toJson()).toList(),
      'simpleModeAchievements':
          instance.simpleModeAchievements.map((e) => e.toJson()).toList(),
    };

GetAchievementsResponse _$GetAchievementsResponseFromJson(
        Map<String, dynamic> json) =>
    GetAchievementsResponse(
      achievements: GetAchievementsResponseBody.fromJson(
          json['achievements'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetAchievementsResponseToJson(
        GetAchievementsResponse instance) =>
    <String, dynamic>{
      'achievements': instance.achievements.toJson(),
    };
