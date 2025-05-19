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

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({super.key});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
      if (state is OTPSuccessState) {
        Navigator.pushReplacementNamed(context, Routes.resetPasswordScreen);
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
                            'Verification code',
                            style: TextStyles.extraBold32White,
                          ),
                          Text(
                            "We have sent the code to your email",
                            style: TextStyles.semiBold18White,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: h * 0.06,
                          ),
                          CustomTextFormField(
                            hintText: "OTP",
                            controller: cubit.otpController,
                            validator: ValidateInput.username,
                          ),
                          SizedBox(
                            height: h * 0.06,
                          ),
                          CustomPrimaryButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context
                                      .read<ForgetPasswordCubit>()
                                      .verifyOTP();
                                }
                              },
                              buttonText: "Verify",
                              height: 45,
                              isLoading: state is OTPSendingState),
                          SizedBox(
                            height: h * 0.06,
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
