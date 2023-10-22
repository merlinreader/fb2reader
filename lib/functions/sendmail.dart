import 'package:url_launcher/url_launcher.dart';

// функция для email
void sendEmail() async {
  final Uri emailLaunchUri =
      Uri(scheme: 'mailto', path: 'readermerlin@gmail.com');
  launchUrl(
    emailLaunchUri,
    mode: LaunchMode.platformDefault,
  );
}
