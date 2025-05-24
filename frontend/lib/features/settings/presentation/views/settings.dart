import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/widget/dialogs.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/custom_single_listtile.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/divider_box.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_application_2/game/services/audio_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/snackabars.dart';

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
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _loadAudioSettings();
  }

  Future<void> _loadAudioSettings() async {
    await _audioManager.initialize();
    setState(() {
      master = _audioManager.getMusicVolume();
      sfx = _audioManager.getSfxVolume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserInitial) {
            Navigator.pushReplacementNamed(context, Routes.loginScreen);
          } else if (state is UpdateError) {
            Snackbars.showErrorSnackbar(context, state.failure.message);
          }
          if (state is UserDeleting) {
            Dialogs.loadingDialog(context: context);
          }
        },
        child: _buildSettingsContent(context));
  }

  Widget _buildSettingsContent(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BackgroundTheme(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04, vertical: h * 0.02),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: h * 0.032),
                        Text('Settings', style: TextStyles.extraBold28White),
                        SizedBox(height: h * 0.024),
                        CustomSingleListTile(
                            titleText: 'Edit your information',
                            leadingIcon: Icons.person_outline,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, Routes.personalInfoScreen);
                            }),
                        SizedBox(height: h * 0.005),
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
                                        const Icon(Icons.music_note, size: 28),
                                        const SizedBox(width: 8),
                                        Text("Music",
                                            style: TextStyles.semiBold16White),
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
                                          inactiveColor: ColorManager.greyColor,
                                          max: 100,
                                          label: master.round().toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              master = value;
                                              _audioManager
                                                  .setMusicVolume(value / 100);
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
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.volume_up, size: 28),
                                          const SizedBox(width: 8),
                                          Text("SFX",
                                              style:
                                                  TextStyles.semiBold16White),
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
                                          inactiveColor: ColorManager.greyColor,
                                          max: 100,
                                          label: sfx.round().toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              sfx = value;
                                              _audioManager
                                                  .setSfxVolume(value / 100);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        SizedBox(height: h * 0.02),
                        CustomSingleListTile(
                            titleText: 'About',
                            leadingIcon: Icons.info_outline,
                            onTap: () {}),
                        SizedBox(height: h * 0.02),
                        DividerBox(
                            child1: ListTile(
                              leading: const Icon(
                                Icons.delete,
                                size: 28,
                                color: ColorManager.errorColor,
                              ),
                              title: Text("Delete Account",
                                  style: TextStyles.semiBold16Error),
                              onTap: () {
                                Dialogs.confirmDialog(
                                  context: context,
                                  title: 'Delete Account',
                                  content:
                                      'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context.read<UserCubit>().deleteAccount();
                                  },
                                );
                              },
                            ),
                            child2: ListTile(
                              leading: const Icon(
                                Icons.logout,
                                size: 28,
                                color: ColorManager.errorColor,
                              ),
                              title: Text("Logout",
                                  style: TextStyles.semiBold16Error),
                              onTap: () {
                                Dialogs.confirmDialog(
                                  context: context,
                                  title: 'Logout',
                                  content: 'Are you sure you want to logout?',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context.read<UserCubit>().logout();
                                  },
                                );
                              },
                            ))
                      ])))),
    );
  }
}
