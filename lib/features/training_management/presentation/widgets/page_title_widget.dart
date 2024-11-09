import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../assets/app_colors.dart';
import '../bloc/training_management_bloc.dart';

class PageTitleWidget extends StatelessWidget {
  const PageTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/trainings');
                context
                    .read<TrainingManagementBloc>()
                    .add(const ClearSelectedTrainingEvent());
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              context.tr('training_detail_page_title_edit'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
