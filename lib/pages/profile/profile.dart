import 'package:flutter/material.dart';

import 'package:merlin/components/appbar/appbar.dart';
import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/components/svg/svg_widget.dart';
//import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';

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
                Text24(text: 'Мой профиль'),
              ],
            )),
        const SizedBox(height: 24),
        const Center(
          child: Column(
            children: [
              MerlinWidget(),
              SizedBox(height: 12),
              Text24(text: 'Merlin'),
              Text14(text:'Страна, область, город'), //когда подключим хрень для получения геолокации надо заменить
              SizedBox(height: 12),
              
            ],
          ),
        ),
      ]),
    );
  }
}
