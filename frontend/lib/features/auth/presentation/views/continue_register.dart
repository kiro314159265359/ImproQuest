import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_cubit.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/snackabars.dart';

class ContinueRegister extends StatefulWidget {
  const ContinueRegister({super.key});

  @override
  State<ContinueRegister> createState() => _ContinueRegisterState();
}

class _ContinueRegisterState extends State<ContinueRegister> {
  List<bool> isSelected = [true, false];
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
      if (state is RegisterSuccessState) {
        Navigator.pushReplacementNamed(context, Routes.loginScreen);
      }
      if (state is RegisterErrorState) {
        Snackbars.showErrorSnackbar(context, state.failure.message);
      }
    }, builder: (context, state) {
      var cubit = context.read<RegisterCubit>();

      return Scaffold(
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
                        Text(
                          "Getting Started",
                          style: TextStyles.extraBold32White,
                        ),
                        SizedBox(
                          height: h * 0.04,
                        ),
                        CustomTextFormField(
                          hintText: "Username",
                          controller: cubit.userNameController,
                          validator: ValidateInput.username,
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        CustomTextFormField(
                          hintText: "Weight",
                          controller: cubit.weightController,
                          validator: ValidateInput.weight,
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        CustomTextFormField(
                          hintText: "Height",
                          controller: cubit.heightController,
                          validator: ValidateInput.height,
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        CustomTextFormField(
                          hintText: "Birthday",
                          controller: cubit.birthDayController,
                          showCalendarIcon: true,
                          validator: ValidateInput.birthday,
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Gender",
                                style: TextStyles.bold16lightGrey,
                              ),
                              ToggleButtons(
                                isSelected: isSelected,
                                onPressed: (index) {
                                  setState(() {
                                    for (int i = 0;
                                        i < isSelected.length;
                                        i++) {
                                      isSelected[i] = i == index;
                                    }
                                  });
                                },
                                // borderRadius: BorderRadius.circular(8),
                                selectedBorderColor: ColorManager.primaryColor,
                                selectedColor: ColorManager.whiteColor,
                                color: ColorManager.darkGreyColor,
                                constraints: const BoxConstraints(
                                    minHeight: 40, minWidth: 100),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.male,
                                          color: isSelected[0]
                                              ? ColorManager.whiteColor
                                              : ColorManager.darkGreyColor),
                                      SizedBox(width: w * 0.02),
                                      const Text('Male'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.female,
                                          color: isSelected[1]
                                              ? ColorManager.whiteColor
                                              : ColorManager.darkGreyColor),
                                      SizedBox(width: w * 0.02),
                                      const Text('Female'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        CustomPrimaryButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<RegisterCubit>().registerUser(
                                  isSelected[0] ? 'Male' : 'Female');
                            }
                          },
                          buttonText: "Register",
                          isLoading: state is RegisterLoadingState,
                        ),
                        SizedBox(
                          height: h * 0.02,
                        ),
                        BackButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      );
    });
  }
}
