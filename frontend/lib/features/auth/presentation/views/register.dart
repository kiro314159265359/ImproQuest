import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../data/api/register_api.dart';
import '../manager/register_cubit/register_cubit.dart';
import '../manager/register_cubit/register_state.dart';

class RegisterArguments {
  final String email;
  final String password;

  RegisterArguments(this.email, this.password);
}

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
    return BlocProvider(
        create: (context) => RegisterCubit(RegisterApi()),
        child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
          if (state is RegisterSuccessState) {
            Navigator.pushReplacementNamed(
                context, Routes.continueRegisterScreen);
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
                                  style: TextStyles.semiBold18White,
                                ),
                                SizedBox(
                                  width: w * 0.03,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                        context, Routes.loginScreen);
                                  },
                                  child: Text(
                                    "login",
                                    style: TextStyles.semiBold18Primary,
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
                              validator: (value) =>
                                  ValidateInput.confirmPassword(
                                      value, cubit.passController.text),
                              obscureText: true,
                            ),
                            SizedBox(
                              height: h * 0.035,
                            ),
                            CustomPrimaryButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.continueRegisterScreen,
                                    arguments: RegisterArguments(
                                        cubit.emailController.text,
                                        cubit.passController.text),
                                  );
                                }
                              },
                              buttonText: "Continue",
                              height: 45,
                              isLoading: state is RegisterLoadingState,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          );
        }));
  }
}
