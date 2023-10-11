import 'package:flutter/material.dart';

import 'package:merlin/style/colors.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/style/text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(64);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: MyColors.white,
        elevation: 1,
        leading: const Center(
          child: Row(
            children: [LogoWidget(), Text24(text: 'Merlin')],
          ),
        ));
  }
}
