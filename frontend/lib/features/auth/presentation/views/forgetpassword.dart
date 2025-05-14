import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/forget_password_cubit/forget_password_cubit.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/forget_password_cubit/forget_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_text_form_field.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocProvider(
        create: (context) => ForgetPasswordCubit(getIt<LoginRepo>()),
        child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            listener: (context, state) {
          if (state is EmailSuccessState) {
            Navigator.pop(context);
          }
          if (state is EmailErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
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
                                'Reset Password',
                                style: TextStyles.extraBold32White,
                              ),
                              Text(
                                "Enter the email to send Verification code ",
                                style: TextStyles.semiBold18White,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: h * 0.06,
                              ),
                              CustomTextFormField(
                                hintText: "Email",
                                controller: cubit.emailController,
                                validator: ValidateInput.email,
                              ),
                              SizedBox(
                                height: h * 0.06,
                              ),
                              CustomPrimaryButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      context
                                          .read<ForgetPasswordCubit>()
                                          .forgetPassword();
                                    }
                                  },
                                  buttonText: "Send",
                                  height: 45,
                                  isLoading: state is EmailSendingState),
                              SizedBox(
                                height: h * 0.06,
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
                  )));
        }));
  }
}
