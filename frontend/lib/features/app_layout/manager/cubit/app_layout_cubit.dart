import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/profile/views/profile.dart';
import 'package:flutter_application_2/features/rankings/views/rankings.dart';
import 'package:flutter_application_2/features/settings/views/settings.dart';

import '../../../home/views/home.dart';
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
