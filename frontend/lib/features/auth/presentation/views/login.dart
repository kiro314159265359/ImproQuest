import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/snackabars.dart';
import '../manager/login_cubit/login_cubit.dart';
import '../manager/login_cubit/login_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocProvider(
        create: (context) => LoginCubit(getIt<LoginRepo>()),
        child: BlocConsumer<LoginCubit, LoginState>(listener: (context, state) {
          if (state is LoginSuccessState) {
            Navigator.pushReplacementNamed(context, Routes.appLayoutScreen);
          }
          if (state is LoginErrorState) {
            Snackbars.showErrorSnackbar(context, state.failure.message);
          }
        }, builder: (context, state) {
          var cubit = context.read<LoginCubit>();

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
                                'Login',
                                style: TextStyles.extraBold32White,
                              ),
                              SizedBox(
                                height: h * 0.02,
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
                                height: h * 0.022,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: 'Forgot password?',
                                        style: TextStyles.bold16Primary,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(context,
                                                Routes.forgetPasswordScreen);
                                          }),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: h * 0.022,
                              ),
                              CustomPrimaryButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<LoginCubit>().loginUser();
                                    }
                                  },
                                  buttonText: "Login",
                                  height: 45,
                                  isLoading: state is LoginLoadingState),
                              SizedBox(
                                height: h * 0.05,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Not a player yet?",
                                    style: TextStyles.bold16Grey,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Register',
                                      style: TextStyles.bold16Primary,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushReplacementNamed(
                                              context, Routes.registerScreen);
                                        },
                                    ),
                                  ),
                                ],
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
