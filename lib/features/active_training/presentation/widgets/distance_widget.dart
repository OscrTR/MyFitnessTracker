import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';

import '../../../../app_colors.dart';

class DistanceWidget extends StatelessWidget {
  final String timerId;
  const DistanceWidget({super.key, required this.timerId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<ActiveTrainingBloc, ActiveTrainingState>(
              builder: (context, state) {
            if (state is ActiveTrainingLoaded) {
              final distance = state.timersStateList
                      .firstWhereOrNull((el) => el.timerId == timerId)
                      ?.distance ??
                  0;
              return Text(
                (distance / 1000).toStringAsFixed(2),
                style: const TextStyle(color: AppColors.frenchGray),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
