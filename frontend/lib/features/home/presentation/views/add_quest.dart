import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/snackabars.dart';

class AddQuest extends StatefulWidget {
  final bool isEditing;
  final Quests? quest;

  const AddQuest({
    super.key,
    this.isEditing = false,
    this.quest,
  });

  @override
  State<AddQuest> createState() => _AddQuestState();
}

class _AddQuestState extends State<AddQuest> {
  final formKey = GlobalKey<FormState>();
  TextEditingController questNameController = TextEditingController();
  String? questType = 'Mental';

  double questDifficultyLevel = 0;
  List<String> difficulty = [
    'Weakling',
    'Fighter',
    'Raider',
    'Elite Hunter',
    'High Awakening',
    'Monarch'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.quest != null) {
      questNameController.text = widget.quest?.name ?? '';
      questType = widget.quest!.type;

      switch (widget.quest!.xpReward) {
        case 10:
          questDifficultyLevel = 0.0;
          break;
        case 20:
          questDifficultyLevel = 1.0;
          break;
        case 30:
          questDifficultyLevel = 2.0;
          break;
        case 40:
          questDifficultyLevel = 3.0;
          break;
        case 50:
          questDifficultyLevel = 4.0;
          break;
        case 60:
          questDifficultyLevel = 5.0;
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    questNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is UserUpdated) {
        Snackbars.showSuccessSnackbar(
            context,
            widget.isEditing
                ? "The Quest has been updated!"
                : "The Quest has been added!");

        Navigator.pushReplacementNamed(context, Routes.appLayoutScreen);
      }
      if (state is UpdateError) {
        Snackbars.showErrorSnackbar(context, state.failure.message);
      }
    }, builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorManager.navyColor,
            title: Text(
              widget.isEditing ? 'Edit Quest' : 'Add Quest',
              style: TextStyles.extraBold24White,
            ),
          ),
          body: Form(
              key: formKey,
              child: BackgroundTheme(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04, vertical: h * 0.02),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextFormField(
                            hintText: "Quest Name",
                            controller: questNameController,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter quest name'
                                : null,
                          ),
                          SizedBox(
                            height: h * 0.02,
                          ),
                          LabelBox(
                            labelText: "Quest Type",
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorManager.fadedNavy,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownButton<String>(
                                  isDense: true,
                                  elevation: 0,
                                  value: questType,
                                  isExpanded: true,
                                  dropdownColor: ColorManager.gunmetal,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: ColorManager.whiteColor,
                                  ),
                                  items: ['Mental', 'Habit'].map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: TextStyles.semiBold16White,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      questType = value;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  underline: const SizedBox(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: h * 0.02,
                          ),
                          LabelBox(
                            labelText:
                                "Difficulty: ${difficulty[questDifficultyLevel.toInt()]}",
                            child: SliderTheme(
                              data: const SliderThemeData(
                                activeTrackColor: ColorManager.primaryColor,
                                trackHeight: 7,
                              ),
                              child: Slider(
                                value: questDifficultyLevel,
                                max: 5,
                                divisions: 5,
                                label: difficulty[questDifficultyLevel.toInt()],
                                onChanged: (value) {
                                  setState(() {
                                    questDifficultyLevel = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: h * 0.02,
                          ),
                          CustomPrimaryButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (widget.isEditing &&
                                      widget.quest != null) {
                                    getIt<UserCubit>().editQuest(
                                      widget.quest!,
                                      questNameController.text,
                                      questDifficultyLevel.toInt(),
                                      questType!,
                                    );
                                  } else {
                                    getIt<UserCubit>().addCustomQuest(
                                        questNameController.text,
                                        questDifficultyLevel.toInt(),
                                        questType!);
                                  }
                                }
                              },
                              buttonText:
                                  widget.isEditing ? "Save Changes" : "Add",
                              isLoading: state is UserUpdating),
                        ],
                      ),
                    ),
                  ),
                ),
              )));
    });
  }
}
