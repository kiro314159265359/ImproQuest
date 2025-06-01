import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/item_button.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/stats_list_tile.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/inventory_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/widget/dialogs.dart';
import '../../../../core/widget/snackabars.dart';
import '../manager/character_cubit.dart';
import '../manager/character_state.dart';

class Character extends StatefulWidget {
  const Character({super.key});

  @override
  State<Character> createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CharacterCubit, CharacterState>(
          listener: (context, state) {
            if (state is SkillPointUpdating) {
              Dialogs.loadingDialog(context: context);
            } else if (state is SkillPointSuccess) {
              Navigator.pop(context);
            } else if (state is SkillPointError) {
              Navigator.pop(context);
              Snackbars.showErrorSnackbar(context, state.failure.message);
            }
          },
        ),
      ],
      child: BlocBuilder<UserCubit, UserState>(
        buildWhen: (previous, current) =>
            current is UserLoaded ||
            current is UserUpdated ||
            current is UserError,
        builder: (context, state) {
          if (state is UserLoaded) {
            return _buildCharacterContent(state.user);
          }
          if (state is UserUpdated) {
            return _buildCharacterContent(state.user);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCharacterContent(UserModel user) {
    // final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ItemButton(
                    width: 56,
                    height: 56,
                    itemPhoto: AppImages.helmetPhoto,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const InventoryUI(title: 'Helmet'),
                      );
                    },
                  ),
                  SizedBox(height: h * 0.024),
                  ItemButton(
                    width: 56,
                    height: 56,
                    itemPhoto: AppImages.armorPhoto,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const InventoryUI(title: 'Armor'),
                      );
                    },
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                          color: ColorManager.gunmetal,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      width: 88,
                      height: 160,
                      child: Image.asset(AppImages.shinobiPhoto,
                          width: 25, fit: BoxFit.contain)),
                  SizedBox(height: h * 0.024),
                  ItemButton(
                    width: 56,
                    height: 56,
                    itemPhoto: AppImages.swordPhoto,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const InventoryUI(title: 'Weapon'),
                      );
                    },
                  )
                ],
              ),
              Column(
                children: [
                  ItemButton(
                    width: 56,
                    height: 56,
                    itemPhoto: AppImages.glovesPhoto,
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (_) => const InventoryUI(title: 'Gloves'),
                      );
                    },
                  ),
                  SizedBox(height: h * 0.024),
                  ItemButton(
                    width: 56,
                    height: 56,
                    itemPhoto: AppImages.bootsPhoto,
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (_) => const InventoryUI(title: 'Boots'),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: h * 0.024),
          Card(
            color: ColorManager.gunmetal,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "SKILL POINTS : ${user.skillPoints ?? 0}",
                    style: TextStyles.bold16White,
                  ),
                ),
                StatsListTile(
                    statName: "STRENGTH",
                    statNum: "${user.stats?.strength ?? 0}",
                    statSubName: "ATTACK",
                    statSubNum: "${user.stats?.strength ?? 0}",
                    statIcon: AppIcons.strengthIcon),
                StatsListTile(
                    statName: "ENDURANCE",
                    statNum: "${user.stats?.endurance ?? 0}",
                    statSubName: "DEFENSE",
                    statSubNum: "${user.stats?.endurance ?? 0}",
                    statIcon: AppIcons.enduranceIcon),
                StatsListTile(
                    statName: "VITALITY",
                    statNum: "${user.stats?.vitality ?? 0}",
                    statSubName: "HEALTH",
                    statSubNum: "${user.stats?.vitality ?? 0}",
                    statIcon: AppIcons.vitalityIcon),
                StatsListTile(
                    statName: "AGILITY",
                    statNum: "${user.stats?.agility ?? 0}",
                    statSubName: "SPEED",
                    statSubNum: "${user.stats?.agility ?? 0}",
                    statIcon: AppIcons.agilityIcon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
