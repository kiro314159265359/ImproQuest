// import 'package:flutter/material.dart';
//
// class AppLayoutCubit extends StatefulWidget {
//   const AppLayoutCubit({super.key});
//
//   @override
//   State<AppLayoutCubit> createState() => _AppLayoutCubitState();
// }
//
// class _AppLayoutCubitState extends State<AppLayoutCubit> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/profile/ui/profile.dart';
import 'package:flutter_application_2/features/rankings/ui/rankings.dart';
import 'package:flutter_application_2/features/settings/ui/settings.dart';

import '../../../home/ui/home.dart';
import 'app_layout_state.dart';

class AppLayoutCubit extends Cubit<AppLayoutState> {
  AppLayoutCubit() : super(AppLayoutInitial());

  List<Widget> screens = [
    const Home(),
    const Profile(),
    const Rankings(),
    const Settings(),
  ];

  int currentIndex = 0;

  changeCurrentIndex(int index) {
    currentIndex = index;
    emit(AppLayoutChangeIndex());
  }
}
