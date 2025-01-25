import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/widget/birtday_input.dart';
import '../../core/widget/custom_primary_button.dart';
import '../../core/widget/custom_text_form_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    TextEditingController controller1 = TextEditingController();
    TextEditingController controller2 = TextEditingController();
    TextEditingController controller3 = TextEditingController();
    TextEditingController controller4 = TextEditingController();
    TextEditingController controller5 = TextEditingController();
    TextEditingController controller6 = TextEditingController();
    TextEditingController controller7 = TextEditingController();
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
                        "Register",
                        style: TextStyles.styleExtraBold(context,
                            fontSize: 32, color: ColorManager.whiteColor),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already a player?",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.loginScreen);
                        },
                        child: const Text(
                          "login",
                          style:
                              TextStyle(color: Colors.deepPurple, fontSize: 15),
                        ),
                      )
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
                    hintText: "Email",
                    controller: controller2,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  CustomTextFormField(
                      hintText: "Password",
                      controller: controller3,
                      obscureText: true),
                  const SizedBox(
                    height: 35,
                  ),
                  CustomTextFormField(
                    hintText: "Confirm Password",
                    controller: controller4,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Birthday",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BirthdayInput(
                              dayController: controller5,
                              monthController: controller6,
                              yearController: controller7),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
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
                        constraints:
                            const BoxConstraints(minHeight: 40, minWidth: 100),
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
                  const SizedBox(
                    height: 20,
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
