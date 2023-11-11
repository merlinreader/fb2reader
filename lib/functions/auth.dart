import 'package:url_launcher/url_launcher.dart';

void launchTelegram() {
  final tgUrl = Uri.parse('https://t.me/merlin_auth_bot?start=1');
  launchUrl(tgUrl, mode: LaunchMode.externalApplication);
}
