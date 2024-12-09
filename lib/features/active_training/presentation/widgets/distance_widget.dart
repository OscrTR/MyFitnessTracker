import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/bloc/active_training_bloc.dart';

class DistanceWidget extends StatefulWidget {
  final String activeRunId;
  const DistanceWidget({super.key, required this.activeRunId});

  @override
  State<DistanceWidget> createState() => DistanceWidgetState();
}

class DistanceWidgetState extends State<DistanceWidget> {
  double distance = 0;
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
              if (state.activeRunTimer == widget.activeRunId) {
                distance = state.distance;
              }
              return Text(
                (distance / 1000).toStringAsFixed(2),
                style: const TextStyle(color: AppColors.lightBlack),
              );
            }
            return const Text(
              '0',
              style: TextStyle(color: AppColors.lightBlack),
            );
          }),
        ],
      ),
    );
  }
}
