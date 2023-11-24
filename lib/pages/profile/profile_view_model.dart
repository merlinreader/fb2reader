import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';

class ProfileViewModel extends ChangeNotifier {
  BuildContext context;
  Uint8List? storedAvatar;

  ProfileViewModel(this.context) {
    _initAsync();
  }

  Future<void> _initAsync() async {
    storedAvatar = await AvatarProvider.getAvatarBytes();
    notifyListeners();
  }

  Future<void> setNewAvatar(bool? avatarChanged) async {
    if (avatarChanged == null) {
      return;
    }
    storedAvatar = avatarChanged ? await AvatarProvider.getAvatarBytes() : null;
    notifyListeners();
  }
}
