import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../manager/register_cubit/register_cubit.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
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
                        "Register",
                        style: TextStyles.extraBold32White,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a player?",
                            style: TextStyles.semiBold16White,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, Routes.loginScreen);
                            },
                            child: Text(
                              "login",
                              style: TextStyles.semiBold16Primary,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: h * 0.03,
                      ),
                      CustomTextFormField(
                        hintText: "Email",
                        controller: cubit.emailController,
                        validator: ValidateInput.email,
                      ),
                      SizedBox(
                        height: h * 0.02,
                      ),
                      CustomTextFormField(
                          hintText: "Password",
                          controller: cubit.passController,
                          validator: ValidateInput.password,
                          obscureText: true),
                      SizedBox(
                        height: h * 0.02,
                      ),
                      CustomTextFormField(
                        hintText: "Confirm Password",
                        controller: cubit.confPassController,
                        validator: (value) => ValidateInput.confirmPassword(
                            value, cubit.passController.text),
                        obscureText: true,
                      ),
                      SizedBox(
                        height: h * 0.035,
                      ),
                      CustomPrimaryButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pushNamed(
                                context, Routes.continueRegisterScreen);
                          }
                        },
                        buttonText: "Continue",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
