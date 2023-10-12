import 'package:flutter/material.dart';

import 'package:merlin/components/appbar/appbar.dart';
import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/style/colors.dart';
//import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button/button.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomNavBar(),
      body: Column(children: [
        Container(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: const Row(
              children: [
                Text24(
                  text: 'Мой профиль',
                  textColor: MyColors.black,
                ),
              ],
            )),
        const SizedBox(height: 24),
        const Expanded(
          child: Center(
            child: Column(
              children: [
                MerlinWidget(),
                SizedBox(height: 12),
                Text24(
                  text: 'Merlin',
                  textColor: MyColors.black,
                ),
                Text14(
                  text: 'Страна, область, город',
                  textColor: MyColors.black,
                ), //когда подключим хрень для получения геолокации надо заменить
                SizedBox(height: 81),

                Button(
                    text: 'Авторизоваться',
                    width: 312,
                    height: 48,
                    horizontalPadding: 97,
                    verticalPadding: 12,
                    buttonColor: MyColors.puple,
                    textColor: MyColors.white,
                    fontSize: 14,
                    onPressed: pres),
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
                        onPressed: pres),
                  ),
                ),
                SizedBox(height: 24)
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

void pres() {
  print('стас крутой');
}
