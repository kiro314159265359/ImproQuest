import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/widget/custom_primary_button.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/widget/custom_text_form_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final _emailController = TextEditingController();
  // final _passController = TextEditingController();
  // // String _emailError = '';
  // // String _passwordError = '';
  bool? value = false;
  bool obsecurePass = true;

  // void _validateFields() {
  //   if (mounted) {
  //     setState(() {
  //       _emailError =
  //           _emailController.text.isEmpty ? 'This field cannot be empty' : '';
  //       _passwordError =
  //           _passController.text.isEmpty ? 'This field cannot be empty' : '';
  //     });
  //   }
  // }

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
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      'Login',
                      style: TextStyles.styleExtraBold(context,
                          fontSize: 32, color: ColorManager.whiteColor),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFormField(
                    hintText: "Email",
                    controller: controller1,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  CustomTextFormField(
                      hintText: "Password",
                      controller: controller2,
                      obscureText: true),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: value,
                            onChanged: (newValue) {
                              setState(() {
                                value = newValue;
                              });
                            },
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                            recognizer: TapGestureRecognizer()..onTap = () {}),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomPrimaryButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.homepage);
                    },
                    buttonText: "Login",
                    height: 45,
                  ),
                  const SizedBox(
                    height: 20,
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
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 300,
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          "assets/images/google.png",
                          height: 24,
                          width: 24,
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1, // Border width
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 300,
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          "assets/images/facebook.png",
                          height: 24,
                          width: 24,
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1, // Border width
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 300,
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          "assets/images/Social_Icons.png",
                          height: 24,
                          width: 24,
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1, // Border width
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 30,
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
                              Navigator.pushNamed(context, Routes.registerScreen);;
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
      ),
    );
  }
}
