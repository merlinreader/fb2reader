import 'package:flutter/material.dart';

import 'package:merlin/style/colors.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/style/text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MyColors.white,
      elevation: 1,
      title: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LogoWidget(),
          Text24(
            text: 'Merlin',
            textColor: MyColors.black,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 64);
}
