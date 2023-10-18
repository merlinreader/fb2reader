import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:merlin/components/svg/svg_asset.dart';

class Dragon1Widget extends StatelessWidget {
  const Dragon1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center, child: SvgPicture.asset(SvgAsset.dragon1));
  }
}
