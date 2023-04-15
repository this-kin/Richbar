import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final String? icon;
  const CustomIcon({
    Key? key,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: SvgPicture.asset(
        icon!,
        fit: BoxFit.scaleDown,
      ),
    );
  }
}
