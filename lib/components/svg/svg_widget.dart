import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:merlin/components/svg/svg_asset.dart';
import 'package:merlin/pages/profile/profile.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16),
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
          child: SvgPicture.asset(SvgAsset.merlinLogo)),
    );
  }
}

class MerlinWidget extends StatelessWidget {
  const MerlinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center, child: SvgPicture.asset(SvgAsset.merlin));
  }
}

class Dragon1Widget extends StatelessWidget {
  const Dragon1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center, child: SvgPicture.asset(SvgAsset.dragon1));
  }
}

class MerlinStart extends StatelessWidget {
  const MerlinStart({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(SvgAsset.merlinStart);
  }
}
