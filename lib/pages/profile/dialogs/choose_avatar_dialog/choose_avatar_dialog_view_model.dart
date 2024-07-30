// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:http/http.dart' as http;

class ChooseAvatarDialogViewModel extends ChangeNotifier {
  BuildContext context;
  bool isLoading = true;
  List<String> avatarsList = [];
  String? selectedAvatar;
  Uint8List? storedAvatar;

  ChooseAvatarDialogViewModel(this.context) {
    getStoredAvatars();
    getAvatars();
  }

  Future<void> getStoredAvatars() async {
    storedAvatar = await AvatarProvider.getAvatarBytes();
    selectedAvatar = await AvatarProvider.getAvatarUrl();
    notifyListeners();
  }

  Future<void> getAvatars() async {
    isLoading = true;
    notifyListeners();
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? tokenSecure = await secureStorage.read(key: 'token');
    String token = '';
    token = tokenSecure!;

    final url = Uri.parse('https://app.merlin.su/account/achievements');
    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "Merlin/1.0", 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final ach = GetAchievementsResponse.fromJson(jsonResponse);
        final List<Achievement> achievements = [];
        achievements.add(ach.achievements.baby);
        achievements.add(ach.achievements.spell);
        achievements.addAll(ach.achievements.simpleModeAchievements);
        achievements.addAll(ach.achievements.wordModeAchievements);
        avatarsList = achievements.where((achievement) => achievement.isReceived).map((achievement) => achievement.picture).toList();
      }
    } catch (_) {}
    isLoading = false;

    notifyListeners();
  }

  void setSelectedAvatar(String newSelectedAvatar) {
    selectedAvatar = newSelectedAvatar;
    notifyListeners();
  }

  Future<void> onSaveClick() async {
    if (selectedAvatar != null) {
      try {
        await AvatarProvider.setAvatarUrl(selectedAvatar!);
        final response = await http.get(Uri.parse(selectedAvatar!));
        await AvatarProvider.setAvatarBytes(response.bodyBytes);
        storedAvatar = response.bodyBytes;
        String? url = selectedAvatar;
        List<String> parts = url!.split('/');
        String avatarName = parts.last.split('.').first;
        sendAvatar(avatarName);
      } catch (_) {}
    }
    Navigator.pop(context, true);
  }

  Future<void> sendAvatar(avatarName) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? tokenSecure = await secureStorage.read(key: 'token');
    String token = '';
    if (tokenSecure != null) {
      token = tokenSecure;
    }
    String url = 'https://app.merlin.su/account/avatar';
    // ignore: unused_local_variable
    var res = await http.patch(Uri.parse(url),
        headers: {
          "User-Agent": "Merlin/1.0",
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '{"name": "$avatarName"}');
    // print(res.statusCode);
  }

  Future<void> onResetClick() async {
    await sendAvatar("default_avatar");
    await AvatarProvider.removeAvatarBytes();
    await AvatarProvider.removeAvatarUrl();
    Navigator.pop(context, false);
  }
}
