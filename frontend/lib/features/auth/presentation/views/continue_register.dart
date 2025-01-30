import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/data/api/register_api.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_cubit.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import 'package:intl/intl.dart';

class ContinueRegister extends StatefulWidget {
  const ContinueRegister({super.key});

  @override
  State<ContinueRegister> createState() => _ContinueRegisterState();
}

class _ContinueRegisterState extends State<ContinueRegister> {
  List<bool> isSelected = [true, false];
  final formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // final routeArgs =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final email = routeArgs?['email'] ?? '';
    // final password = routeArgs?['password'] ?? '';

    return BlocProvider(
        create: (context) => RegisterCubit(RegisterApi()),
        child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
          if (state is RegisterSuccessState) {
            Navigator.pushReplacementNamed(context, Routes.appLayoutPage);
          }
          if (state is RegisterErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        }, builder: (context, state) {
          var cubit = RegisterCubit.get(context);

          return Scaffold(
            body: Form(
              key: formKey,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorManager.navyColor,
                      ColorManager.deepBlue,
                    ],
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Getting Started",
                                style: TextStyles.styleExtraBold(context,
                                    fontSize: 32,
                                    color: ColorManager.whiteColor),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          CustomTextFormField(
                            hintText: "Username",
                            controller: userNameController,
                            validator: ValidateInput.username,
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          CustomTextFormField(
                            hintText: "Weight",
                            controller: weightController,
                            validator: ValidateInput.weight,
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          CustomTextFormField(
                            hintText: "Height",
                            controller: heightController,
                            validator: ValidateInput.height,
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          CustomTextFormField(
                            hintText: "Birthday",
                            controller: birthDayController,
                            showCalendarIcon: true,
                            validator: ValidateInput.birthday,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Gender",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC5C6D0),
                                  ),
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
                                  selectedBorderColor: const Color(0xFF8766EB),
                                  selectedColor: Colors.white,
                                  color: Colors.white54,
                                  constraints: const BoxConstraints(
                                      minHeight: 40, minWidth: 100),
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.male,
                                            color: isSelected[0]
                                                ? Colors.white
                                                : Colors.white54),
                                        const SizedBox(width: 5),
                                        const Text('Male'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.female,
                                            color: isSelected[1]
                                                ? Colors.white
                                                : Colors.white54),
                                        const SizedBox(width: 5),
                                        const Text('Female'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomPrimaryButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                cubit.registerUser(
                                  cubit.emailController.text,
                                  cubit.passController.text,
                                  userNameController.text,
                                  int.parse(heightController.text),
                                  int.parse(weightController.text),
                                  isSelected[0] ? 'Male' : 'Female',
                                  DateFormat('MM/dd/yyyy')
                                      .parse(birthDayController.text),
                                );
                                // final gender =
                                //     isSelected[0] ? 'Male' : 'Female';
                                // final height = int.parse(heightController.text);
                                // final weight = int.parse(weightController.text);
                                // final birthday = DateFormat('MM/dd/yyyy')
                                //     .parse(birthDayController.text);
                                // // print(email);
                                // // print(password);
                                // print(height);
                                // print(weight);
                                // print(gender);
                                // print(birthday);
                                //
                                // context.read<RegisterCubit>().registerUser(
                                //     // email,
                                //     // password,
                                //     userNameController.text,
                                //     height,
                                //     weight,
                                //     gender,
                                //     birthday);
                              }
                            },
                            buttonText: "Register",
                            height: 45,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }
}
