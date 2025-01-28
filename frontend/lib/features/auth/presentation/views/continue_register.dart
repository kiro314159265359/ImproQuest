import 'package:flutter/material.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';

class ContinueRegister extends StatefulWidget {
  const ContinueRegister({super.key});

  @override
  State<ContinueRegister> createState() => _ContinueRegisterState();
}

class _ContinueRegisterState extends State<ContinueRegister> {
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    TextEditingController controller1 = TextEditingController();
    TextEditingController controller2 = TextEditingController();

    return Scaffold(
      body: Container(
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
                            fontSize: 32, color: ColorManager.whiteColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  CustomTextFormField(
                    hintText: "Username",
                    controller: controller1,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  CustomTextFormField(
                    hintText: "Birthday",
                    controller: controller2,
                    showCalendarIcon: true,
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
                              for (int i = 0; i < isSelected.length; i++) {
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      Navigator.pushNamed(context, Routes.loginScreen);
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
    );
  }
}
