import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/routes.dart';
import 'package:flutter_application_2/core/service/cache_helper.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/features/onboarding/data/onboarding_data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/text_style.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BackgroundTheme(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: OnboardingData.pages,
              ),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: OnboardingData.pages.length,
                effect: const ExpandingDotsEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    dotColor: ColorManager.darkGreyColor,
                    activeDotColor: ColorManager.primaryColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _currentIndex < OnboardingData.pages.length - 1
                      ? TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text("Next", style: TextStyles.bold16Primary),
                        )
                      : TextButton(
                          onPressed: () async {
                            await notFirstTime();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, Routes.loginScreen);
                            }
                          },
                          child: Text("Get Started",
                              style: TextStyles.bold16Primary),
                        ),
                ],
              ),
            ),
            SizedBox(height: h * 0.02),
          ],
        ),
      ),
    );
  }
}
