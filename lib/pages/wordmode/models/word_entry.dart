import 'package:json_annotation/json_annotation.dart';

part 'word_entry.g.dart';

@JsonSerializable()
class WordEntry {
  final String word;
  final int count;
  String? translation;
  String? ipa;

  WordEntry({
    required this.word,
    required this.count,
    this.translation,
    this.ipa,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) =>
      _$WordEntryFromJson(json);

  Map<String, dynamic> toJson() => _$WordEntryToJson(this);

  void add(WordEntry wordEntry) {}
}
