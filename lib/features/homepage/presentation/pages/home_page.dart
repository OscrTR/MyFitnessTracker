import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app_colors.dart';
import '../../../training_management/presentation/bloc/training_management_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildTrainingsList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Widget _buildTrainingsList() {
  return BlocBuilder<TrainingManagementBloc, TrainingManagementState>(
      builder: (context, state) {
    if (state is TrainingManagementLoaded) {
      final plannedTrainings = state.trainings.where((training) =>
          training.trainingDays != null && training.trainingDays!.isNotEmpty);

      if (plannedTrainings.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(left: 20),
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.floralWhite,
              border: Border.all(color: AppColors.parchment),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('home_page_first_training_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 3),
              Text(
                tr('home_page_first_training_description'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.taupeGray),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => GoRouter.of(context).push('/training_detail'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                          color: AppColors.folly,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            tr('global_start'),
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.licorice,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(tr('home_page_planned_today')),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      }
      return Container();
    }
    return const SizedBox();
  });
}
