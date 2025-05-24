import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../manager/cubit/app_layout_cubit.dart';

class CustomBarIcon extends StatelessWidget {
  final AppLayoutCubit cubit;
  final String iconName;
  final int index;
  const CustomBarIcon(
      {super.key,
      required this.cubit,
      required this.iconName,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      AssetImage(iconName),
      color: cubit.currentIndex == index
          ? ColorManager.primaryColor
          : ColorManager.whiteColor,
      size: 24,
    );
  }
}
