import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/app_layout/presentation/views/widgets/custom_bar_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/utils/app_icons.dart';
import '../manager/cubit/app_layout_cubit.dart';
import '../manager/cubit/app_layout_state.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppLayoutCubit(),
        child: BlocBuilder<AppLayoutCubit, AppLayoutState>(
            builder: (context, state) {
          var cubit = context.read<AppLayoutCubit>();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              body: cubit.screens[cubit.currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: ColorManager.deepBlue,
                  selectedItemColor: ColorManager.primaryColor,
                  unselectedItemColor: ColorManager.whiteColor,
                  currentIndex: cubit.currentIndex,
                  onTap: (index) {
                    if (index == 2) {
                      Flame.device.fullScreen();
                      Flame.device.setPortrait();
                      Navigator.pushNamed(context, Routes.gameScreen);
                    } else {
                      cubit.changeCurrentIndex(index);
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: CustomBarIcon(
                        cubit: cubit,
                        iconName: AppIcons.homeIcon,
                        index: 0,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomBarIcon(
                          cubit: cubit,
                          iconName: AppIcons.profileIcon,
                          index: 1),
                      label: 'Profile',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomBarIcon(cubit: cubit, index: 2),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomBarIcon(
                          cubit: cubit,
                          iconName: AppIcons.rankingsIcon,
                          index: 3),
                      label: 'Rankings',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomBarIcon(
                          cubit: cubit,
                          iconName: AppIcons.settingsIcon,
                          index: 4),
                      label: 'Settings',
                    ),
                  ]),
              floatingActionButton: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(
                  math.pi / 4,
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Flame.device.fullScreen();
                    Flame.device.setPortrait();

                    Navigator.pushNamed(context, Routes.gameScreen);
                  },
                  tooltip: 'Fight',
                  elevation: 15.0,
                  backgroundColor: ColorManager.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(
                      -math.pi / 4,
                    ),
                    child: const ImageIcon(
                      AssetImage(AppIcons.fightIcon),
                      color: ColorManager.whiteColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked);
        }));
  }
}
