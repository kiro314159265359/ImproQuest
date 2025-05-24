import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/forget_password_cubit/forget_password_cubit.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/forget_password_cubit/forget_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/snackabars.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
      if (state is ResetPasswordSuccessState) {
        Navigator.pushReplacementNamed(context, Routes.loginScreen);
      }
      if (state is OTPErrorState) {
        Snackbars.showErrorSnackbar(context, state.failure.message);
      }
    }, builder: (context, state) {
      var cubit = context.read<ForgetPasswordCubit>();

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
                            'Create New Password',
                            style: TextStyles.extraBold32White,
                          ),
                          Text(
                            "Enter your new password",
                            style: TextStyles.semiBold16White,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          CustomTextFormField(
                            obscureText: true,
                            hintText: "New Password",
                            controller: cubit.newPasswordController,
                            validator: ValidateInput.password,
                          ),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          CustomTextFormField(
                            obscureText: true,
                            hintText: "Confirm Password",
                            controller: cubit.confirmPasswordController,
                            validator: (value) => ValidateInput.confirmPassword(
                                value, cubit.newPasswordController.text),
                          ),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          CustomPrimaryButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context
                                      .read<ForgetPasswordCubit>()
                                      .resetPassword();
                                }
                              },
                              buttonText: "Confirm",
                              isLoading: state is ResetPasswordSendingState),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          BackButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, Routes.loginScreen);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )));
    });
  }
}
