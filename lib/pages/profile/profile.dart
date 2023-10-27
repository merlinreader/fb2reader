import 'package:flutter/material.dart';
//import 'package:merlin/components/appbar/appbar.dart';
//import 'package:merlin/components/navbar/navbar.dart';

import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button/button.dart';
import 'package:merlin/functions/sendmail.dart';
import 'package:merlin/functions/location.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String country;
  late String adminArea;
  late String locality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: const Row(
              children: [
                Text24(
                  text: 'Мой профиль',
                  textColor: MyColors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
              child: Column(children: [
            const MerlinWidget(),
            const SizedBox(height: 12),
            const Text24(
              text: 'Merlin',
              textColor: MyColors.black,
            ),
            FutureBuilder(
                future: getLocation(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.data == null) {
                    return const Text('Мы тебя не видим, включи геолокацию');
                  } else {
                    return Text('${snapshot.data}');
                  }
                }),
          ])),
          const SizedBox(height: 81),
          const Expanded(
            child: Column(
              children: [
                Button(
                  text: 'Авторизоваться',
                  width: 312,
                  height: 48,
                  horizontalPadding: 97,
                  verticalPadding: 12,
                  buttonColor: MyColors.purple,
                  textColor: MyColors.white,
                  fontSize: 14,
                  onPressed: sendEmail,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Button(
                        text: 'Написать нам',
                        width: 312,
                        height: 48,
                        horizontalPadding: 97,
                        verticalPadding: 12,
                        buttonColor: MyColors.white,
                        textColor: MyColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        onPressed: sendEmail),
                  ),
                ),
                SizedBox(height: 24)
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

void pres() {
  // ignore: avoid_print
  // ignore: avoid_print
  print('стас крутой');
}
