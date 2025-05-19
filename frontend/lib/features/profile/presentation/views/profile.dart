import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/features/profile/presentation/views/statistics.dart';
import 'package:flutter_application_2/features/profile/presentation/views/achievements.dart';
import 'package:flutter_application_2/features/profile/presentation/views/character.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/statistics_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/widget/appbar_stats.dart';
import '../../../home/data/model/user_model.dart';
import '../../../home/presentation/manager/user_cubit.dart';
import '../../../home/presentation/manager/user_state.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: BackgroundTheme(
          child: BlocConsumer<UserCubit, UserState>(
            buildWhen: (previous, current) =>
                current is UserLoaded ||
                current is UserUpdated ||
                current is UserError,
            listener: (context, state) {
              if (state is UserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failure.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is UserLoaded) {
                return _buildProfileContent(state.user);
              }
              if (state is UserUpdated) {
                return _buildProfileContent(state.user);
              }
              if (state is UserLoading) {
                return const StatisticsLoading();
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserModel user) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: h * 0.025),
          const AppBarStats(),
          SizedBox(height: h * 0.025),
          const TabBar(
            dividerColor: Colors.transparent,
            labelColor: ColorManager.primaryColor,
            unselectedLabelColor: ColorManager.darkGreyColor,
            indicatorColor: ColorManager.primaryColor,
            tabs: [
              Tab(text: 'STATS'),
              Tab(text: 'ACHIEVEMENTS'),
              Tab(text: 'CHARACTER'),
            ],
          ),
          Expanded(
            child: TabBarView(
// physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Statistics(user: user,width: w, height: h),
                const Achievements(),
                const Character(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildProfileLoadingContent() {
  //   var w = MediaQuery.of(context).size.width;
  //   var h = MediaQuery.of(context).size.height;
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(height: h * 0.025),
  //         const AppBarStats(),
  //         SizedBox(height: h * 0.025),
  //         const TabBar(
  //           dividerColor: Colors.transparent,
  //           labelColor: ColorManager.primaryColor,
  //           unselectedLabelColor: ColorManager.darkGreyColor,
  //           indicatorColor: ColorManager.primaryColor,
  //           tabs: [
  //             Tab(text: 'STATS'),
  //             Tab(text: 'ACHIEVEMENTS'),
  //             Tab(text: 'CHARACTER'),
  //           ],
  //         ),
  //         const Expanded(
  //           child: TabBarView(
  //             children: <Widget>[
  //               StatisticsLoading(),
  //               Achievements(),
  //               Character(),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
