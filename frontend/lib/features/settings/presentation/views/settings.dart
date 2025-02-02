import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/custom_single_listtile.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/divider_box.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/service/cache_helper.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool popNotificationBool = false;
  bool emailNotificationBool = false;
  double master = 60;
  double sfx = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundTheme(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Text(
                            'Settings',
                            style: TextStyles.styleExtraBold(context,
                                fontSize: 38, color: ColorManager.whiteColor),
                          ),
                        ),
                        const SizedBox(height: 35),
                        CustomSingleListTile(
                            titleText: 'Edit your information',
                            leadingIcon: Icons.person_outline,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Routes.personalInfoPage);
                            }),
                        const SizedBox(height: 5),
                        LabelBox(
                          labelText: "Notifications",
                          child: DividerBox(
                              child1: SwitchListTile(
                                title: Text("Pop Up Notifications",
                                    style: TextStyles.styleSemiBold(context,
                                        fontSize: 18,
                                        color: ColorManager.whiteColor)),
                                value: popNotificationBool,
                                activeTrackColor: ColorManager.primaryColor,
                                secondary: const Icon(Icons.notifications_none,
                                    size: 30),
                                onChanged: (value) {
                                  setState(() {
                                    popNotificationBool = value;
                                  });
                                },
                              ),
                              child2: SwitchListTile(
                                activeTrackColor: ColorManager.primaryColor,
                                secondary:
                                    const Icon(Icons.email_outlined, size: 30),
                                title: Text("Email Notifications",
                                    style: TextStyles.styleSemiBold(context,
                                        fontSize: 18,
                                        color: ColorManager.whiteColor)),
                                value: emailNotificationBool,
                                onChanged: (value) {
                                  setState(() {
                                    emailNotificationBool = value;
                                  });
                                },
                              )),
                        ),
                        const SizedBox(height: 5),
                        LabelBox(
                            labelText: "Sound & Audio",
                            child: DividerBox(
                              child1: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.volume_mute, size: 30),
                                        Text("Master",
                                            style: TextStyles.styleSemiBold(
                                                context,
                                                fontSize: 18,
                                                color:
                                                    ColorManager.whiteColor)),
                                      ],
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 7,
                                        ),
                                        child: Slider(
                                          value: master,
                                          activeColor:
                                              ColorManager.primaryColor,
                                          inactiveColor:
                                              const Color(0xff9B9B9B),
                                          max: 100,
                                          label: 0.5.round().toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              master = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              child2: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 27),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.volume_mute,
                                              size: 30),
                                          Text("SFX",
                                              style: TextStyles.styleSemiBold(
                                                  context,
                                                  fontSize: 18,
                                                  color:
                                                      ColorManager.whiteColor)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 7,
                                        ),
                                        child: Slider(
                                          value: sfx,
                                          activeColor:
                                              ColorManager.primaryColor,
                                          inactiveColor:
                                              const Color(0xff9B9B9B),
                                          max: 100,
                                          label: 0.5.round().toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              sfx = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 20),
                        CustomSingleListTile(
                            titleText: 'About',
                            leadingIcon: Icons.info_outline,
                            onTap: () {}),
                        const SizedBox(height: 20),
                        DividerBox(
                            child1: ListTile(
                              leading: const Icon(
                                Icons.delete,
                                size: 30,
                                color: ColorManager.errorColor,
                              ),
                              title: Text("Delete Account",
                                  style: TextStyles.styleSemiBold(context,
                                      fontSize: 18,
                                      color: ColorManager.errorColor)),
                              onTap: () {
                                clearTokens();
                                Navigator.pushReplacementNamed(
                                    context, Routes.loginScreen);
                              },
                            ),
                            child2: ListTile(
                              leading: const Icon(
                                Icons.logout,
                                size: 30,
                                color: ColorManager.errorColor,
                              ),
                              title: Text("Logout",
                                  style: TextStyles.styleSemiBold(context,
                                      fontSize: 18,
                                      color: ColorManager.errorColor)),
                              onTap: () {
                                clearTokens();
                                Navigator.pushReplacementNamed(
                                    context, Routes.loginScreen);
                              },
                            ))
                      ])))),
    );
  }
}
