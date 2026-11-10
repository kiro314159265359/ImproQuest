import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/presentation/views/home.dart';
import 'package:flutter_application_2/features/profile/presentation/views/profile.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/rankings.dart';
import 'package:flutter_application_2/features/settings/presentation/views/settings.dart';
import 'app_layout_state.dart';

class AppLayoutCubit extends Cubit<AppLayoutState> {
  AppLayoutCubit() : super(AppLayoutInitial());

  List<Widget> screens = [
    const Home(),
    const Profile(),
    const SizedBox.shrink(),
    const Rankings(),
    const Settings(),
  ];

  int currentIndex = 0;

  changeCurrentIndex(int index) {
    currentIndex = index;
    emit(AppLayoutChangeIndex());
  }
}
