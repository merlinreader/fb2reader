import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: MyColors.white,
        elevation: 1,
        leading: Center(
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.only(left: 24, right: 16),
                  child: SvgPicture.asset(
                    'merlin.svg',
                  )),
              const Text('Merlin',
                  style: TextStyle(
                      fontFamily: 'Tektur', color: Colors.black, fontSize: 24))
            ],
          ),
        ));
  }
}