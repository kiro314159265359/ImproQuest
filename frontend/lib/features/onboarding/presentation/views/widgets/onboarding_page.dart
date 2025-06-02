import 'package:flutter/material.dart';
import '../../../../../core/theme/text_style.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String body;
  const OnboardingPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imagePath,
      required this.body});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: w * 0.6, fit: BoxFit.contain),
        SizedBox(height: h * 0.04),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Text(title,
              style: TextStyles.extraBold28White, textAlign: TextAlign.center),
        ),
        SizedBox(height: h * 0.024),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Text(subtitle,
                textAlign: TextAlign.center, style: TextStyles.bold20White)),
        SizedBox(height: h * 0.024),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.08),
            child: Text(body,
                textAlign: TextAlign.center, style: TextStyles.regular14White))
      ],
    );
  }
}
