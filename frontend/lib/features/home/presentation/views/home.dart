import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/widget/appbar_stats.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quest_card.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../data/model/user_model.dart';
import '../manager/user_cubit.dart';
import '../manager/user_state.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundTheme(
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoaded) {
              return _buildHomeContent(state.user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(UserModel user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const AppBarStats(),
            const SizedBox(height: 25),
            CustomRichText(
              text1: 'Welcome, ',
              textStyle1: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.whiteColor),
              text2: user.username ?? 'Player',
              textStyle2: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.primaryColor),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 150,
              child: Card(
                color: ColorManager.gunmetal,
                //TODO: Clean this BS
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                // decoration: const BoxDecoration(
                //     color: ColorManager.gunmetal,
                //     borderRadius: BorderRadius.all(Radius.circular(12))),
                // width: double.infinity,
                // height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("DAILY QUESTS",
                            style: TextStyles.styleBold(context,
                                fontSize: 24, color: ColorManager.whiteColor),
                            textAlign: TextAlign.center),
                        CustomRichText(
                          text1: '1 Quest ',
                          textStyle1: TextStyles.styleSemiBold(context,
                              fontSize: 18, color: const Color(0xFFA4FF72)),
                          text2: 'completed',
                          textStyle2: TextStyles.styleSemiBold(context,
                              fontSize: 18, color: const Color(0xFFB7B7B9)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: ColorManager.containerBackGround,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text("3 Quests left",
                              style: TextStyles.styleSemiBold(context,
                                  fontSize: 18, color: ColorManager.whiteColor),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    CircularPercentIndicator(
                        animation: true,
                        widgetIndicator: Transform.translate(
                          offset: const Offset(-5, 0),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.black,
                            size: 9, // Icon size
                          ),
                        ),
                        backgroundColor: ColorManager.containerBackGround,
                        radius: 60,
                        lineWidth: 10.0,
                        percent: 0.25,
                        center: Text("25%",
                            style: TextStyles.styleSemiBold(context,
                                fontSize: 20, color: ColorManager.whiteColor),
                            textAlign: TextAlign.center),
                        linearGradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: <Color>[
                              Color(0xFFA4FF72),
                              Color(0xFFA4FF72)
                            ]),
                        rotateLinearGradient: true,
                        circularStrokeCap: CircularStrokeCap.round)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const CustomQuestCard(
                questName: "LOGIN",
                questDesc: "Check-in to your system today.",
                goal: 1,
                questImageIcon: AssetImage('assets/icons/LoginChIcon.png'),
                progress: 1),
            const SizedBox(height: 5),
            const CustomQuestCard(
                questName: "RUNNING",
                questDesc: "Run 1km [ 100XP ]",
                goal: 1000,
                questImageIcon: AssetImage('assets/icons/RunningChIcon.png'),
                progress: 0.5)
          ],
        ),
      ),
    );
  }
}
