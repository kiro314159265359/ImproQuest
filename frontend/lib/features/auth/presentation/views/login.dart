import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import '../../../../core/utils/validate_input.dart';
import '../../../../core/widget/custom_primary_button.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../manager/login_cubit/login_cubit.dart';
import '../manager/login_cubit/login_state.dart';

final getIt = GetIt.instance;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool rememberMe = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return BlocProvider(
        create: (context) => LoginCubit(getIt<LoginRepo>()),
        child: BlocConsumer<LoginCubit, LoginState>(listener: (context, state) {
          if (state is LoginSuccessState) {
            Navigator.pushReplacementNamed(context, Routes.appLayoutPage);
          }
          if (state is LoginErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        }, builder: (context, state) {
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
                                style: TextStyles.styleExtraBold(context,
                                    fontSize: 32,
                                    color: ColorManager.whiteColor),
                              ),
                              SizedBox(
                                height: h * 0.02,
                              ),
                              CustomTextFormField(
                                hintText: "Email",
                                controller: emailController,
                                validator: ValidateInput.email,
                              ),
                              SizedBox(
                                height: h * 0.02,
                              ),
                              CustomTextFormField(
                                  hintText: "Password",
                                  controller: passController,
                                  validator: ValidateInput.password,
                                  obscureText: true),
                              SizedBox(
                                height: h * 0.02,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: ColorManager.primaryColor,
                                        value: rememberMe,
                                        onChanged: (newValue) {
                                          setState(() {
                                            rememberMe = newValue!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Remember me",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: 'Forgot password?',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8766EB),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {}),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: h * 0.02,
                              ),
                              CustomPrimaryButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<LoginCubit>().loginUser(
                                          emailController.text,
                                          passController.text,
                                          rememberMe);
                                    }
                                  },
                                  buttonText: "Login",
                                  height: 45,
                                  isLoading: state is LoginLoadingState),
                              SizedBox(
                                height: h * 0.02,
                              ),
                              const Row(children: [
                                Expanded(
                                    child: Divider(
                                  thickness: 2,
                                  indent: 10,
                                  endIndent: 9,
                                )),
                                Text(
                                  "OR",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                  thickness: 2,
                                  indent: 10,
                                  endIndent: 14,
                                )),
                              ]),
                              SizedBox(
                                height: h * 0.03,
                              ),
                              SizedBox(
                                  width: w * 0.7,
                                  height: 47,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      "assets/images/google.png",
                                      height: h * 0.06,
                                      width: w * 0.06,
                                    ),
                                    label: const Text(
                                      "Sign in with Google",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 1, // Border width
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                height: h * 0.03,
                              ),
                              SizedBox(
                                  width: w * 0.7,
                                  height: 47,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      "assets/images/facebook.png",
                                      height: h * 0.06,
                                      width: w * 0.06,
                                    ),
                                    label: const Text(
                                      "Sign in with Facebook",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 1, // Border width
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                height: h * 0.03,
                              ),
                              SizedBox(
                                  width: w * 0.7,
                                  height: 47,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      "assets/images/Social_Icons.png",
                                      height: h * 0.06,
                                      width: w * 0.06,
                                    ),
                                    label: const Text(
                                      "Sign in with Apple",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 1, // Border width
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                height: h * 0.03,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Not a player yet?",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Register',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8766EB),
                                      ),
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
