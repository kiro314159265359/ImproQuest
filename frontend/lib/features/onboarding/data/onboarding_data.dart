import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import '../presentation/views/widgets/onboarding_page.dart';

class OnboardingData {
  static final List<Widget> pages = [
    const OnboardingPage(
      title: "Welcome to ImproQuest",
      subtitle: "Turn Your Life Into An Adventure",
      imagePath: AppImages.onboardingPhoto1,
      body:
          "Transform your daily habits into an epic quest! Every step you take, every goal you complete makes you stronger. Ready to become the hero of your own story?",
    ),
    const OnboardingPage(
      title: "Two Types of Quests Await",
      subtitle: "Your Path to Growth",
      imagePath: AppImages.onboardingPhoto2,
      body:
          "Main Quests: Daily running challenges tracked automatically by your device. Custom Quests: Personal goals you set yourself - from reading books to drinking more water. Complete them to earn XP and gold!",
    ),
    const OnboardingPage(
      title: "Level Up Your Character",
      subtitle: "Grow Stronger Every Day",
      imagePath: AppImages.onboardingPhoto3,
      body:
          "Gain XP from completed quests to level up! Each level grants skill points to boost your stats: Vitality (health), Strength (attack), Endurance (stamina), and Agility (speed). These stats power your character in battle!",
    ),
    const OnboardingPage(
      title: "Battle Your Way to Victory",
      subtitle: "Turn-Based Strategic Combat",
      imagePath: AppImages.onboardingPhoto4,
      body:
          "Use your hard-earned stats in thrilling turn-based battles! Choose your strategy: attack, defend, or use items. Your real-world improvements directly impact your combat prowess!",
    ),
    const OnboardingPage(
      title: "Spend Your Hard-Earned Gold",
      subtitle: "Permanent Gear & Battle Items",
      imagePath: AppImages.onboardingPhoto5,
      body:
          "Gold from quests unlocks powerful equipment and consumables. Buy permanent armor and weapons, or spend on temporary battle items. Every purchase makes you stronger!",
    ),
    const OnboardingPage(
      title: "Climb the Leaderboards",
      subtitle: "Compete Across All Tiers",
      imagePath: AppImages.onboardingPhoto6,
      body:
          "Challenge players in your tier on Streak and Level Rankings. Consistency and dedication will crown you the champion of your tier!",
    ),
    const OnboardingPage(
      title: "Your Quest Begins Now",
      subtitle: "Ready to Transform Your Life?",
      imagePath: AppImages.onboardingPhoto7,
      body:
          "Start your journey with your first running quest and custom goals. Every step forward makes you stronger, every day completed builds your legacy. Adventure awaits!",
    ),
  ];
}
