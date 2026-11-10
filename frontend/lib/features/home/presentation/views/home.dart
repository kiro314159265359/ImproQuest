import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_event.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/home_content.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => getIt<HomeBloc>()..add(HomeInitialized()),
      child: const HomeContent(),
    );
  }
}
