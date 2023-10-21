import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:merlin/components/svg/svg_asset.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16),
      child: Align(
          alignment: Alignment.center,
          child: SvgPicture.asset(SvgAsset.merlinLogo)),
    );
  }
}

class MerlinWidget extends StatelessWidget {
  const MerlinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(SvgAsset.merlin));
  }
}
