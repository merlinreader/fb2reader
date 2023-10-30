import 'package:url_launcher/url_launcher.dart';

void launchTelegram() async {
  final tgUrl = Uri.parse(
      'https://oauth.telegram.org/auth?bot_id=6409671267&origin=https%3A%2F%2Ffb2.cloud.leam.pro&embed=1&request_access=write&return_to=https%3A%2F%2Ffb2.cloud.leam.pro%2Fapi%2Faccount%2Fwidget');
  await launchUrl(tgUrl, mode: LaunchMode.externalApplication);
}

// https://fb2.cloud.leam.pro/api/account/login?id=702336469&first_name=%3E%20cls&username=bboy55&
//  photo_url=https%3A%2F%2Ft.me%2Fi%2Fuserpic%2F320%2FKGg_hWQQHvs__4FX7BYlAG4zzorn2aCtx3_U5Pyp254.jpg&auth_date=1698395805&hash=eb206df2bc7d75e8c81dfd5b29e6d9e827202fe22d12536945553b8b42fd3c96