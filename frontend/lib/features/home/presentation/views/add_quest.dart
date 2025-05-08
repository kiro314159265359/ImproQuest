import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';

class AddQuest extends StatefulWidget {
  const AddQuest({super.key});

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
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocConsumer<UserCubit, UserState>(listener: (context, state) {
      if (state is UserUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("The Quest has been added!")),
        );
        Navigator.pushReplacementNamed(context, Routes.appLayoutScreen);
      }
      if (state is UpdateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure.message)),
        );
      }
    }, builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorManager.navyColor,
            centerTitle: true,
            title: Text(
              'Add Quest',
              style: TextStyles.extraBold28White,
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
                            validator: ValidateInput.username,
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
                                        style: TextStyles.semiBold18White,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      questType = value;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  underline: SizedBox(),
                                  // decoration: InputDecoration(
                                  //   filled: true,
                                  //   fillColor:
                                  //       ColorManager.gunmetal.withValues(alpha: .6),
                                  //   border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(16),
                                  //     borderSide: BorderSide.none,
                                  //   ),
                                  //   labelText: 'Quest Type',
                                  //   hintStyle: const TextStyle(
                                  //       color: ColorManager.lightGrey, fontSize: 20),
                                  // ),
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
                          SizedBox(
                            height: h * 0.02,
                          ),
                          CustomPrimaryButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  getIt<UserCubit>().addCustomQuest(
                                      questNameController.text,
                                      questDifficultyLevel.toInt(),
                                      questType!);
                                }
                              },
                              buttonText: "Add",
                              height: 45,
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
