import 'package:flutter/material.dart';
import '../../../core/routes/routes.dart';
import '../../../core/theme/color_manger.dart';
import '../../../core/theme/text_style.dart';
import '../../../core/widget/custom_primary_button.dart';
import '../../../core/widget/custom_text_form_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller1 = TextEditingController();
    TextEditingController controller2 = TextEditingController();
    TextEditingController controller3 = TextEditingController();
    TextEditingController controller4 = TextEditingController();

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
                      Text(
                        "Already a player?",
                        style: TextStyles.styleSemiBold(context,
                            fontSize: 18, color: ColorManager.whiteColor),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.loginScreen);
                        },
                        child: Text(
                          "login",
                          style: TextStyles.styleSemiBold(context,
                              fontSize: 18, color: ColorManager.primaryColor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
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
                    height: 35,
                  ),
                  CustomPrimaryButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, Routes.continueRegisterScreen);
                    },
                    buttonText: "Continue",
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
