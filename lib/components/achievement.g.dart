// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      description: json['description'] as String,
      date: json['date'] as String?,
      picture: json['picture'] as String,
      isReceived: json['isReceived'] as bool,
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'description': instance.description,
      'date': instance.date,
      'picture': instance.picture,
      'isReceived': instance.isReceived,
    };
