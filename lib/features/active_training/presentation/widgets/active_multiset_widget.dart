import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../helper_functions.dart';
import '../../../training_management/domain/entities/multiset.dart';
import '../../../training_management/domain/entities/training_exercise.dart';
import 'active_multiset_exercise_widget.dart';
import 'active_multiset_run_widget.dart';

class ActiveMultisetWidget extends StatefulWidget {
  final Multiset multiset;
  final bool isLast;
  final int multisetIndex;
  const ActiveMultisetWidget({
    super.key,
    required this.isLast,
    required this.multiset,
    required this.multisetIndex,
  });

  @override
  State<ActiveMultisetWidget> createState() => _ActiveMultisetWidgetState();
}

class _ActiveMultisetWidgetState extends State<ActiveMultisetWidget> {
  @override
  Widget build(BuildContext context) {
    final hasSpecialInstructions =
        widget.multiset.specialInstructions != null &&
            widget.multiset.specialInstructions!.isNotEmpty;
    final hasObjectives = widget.multiset.objectives != null &&
        widget.multiset.objectives!.isNotEmpty;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.lightBlack),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('global_multiset')),
                  Row(
                    children: [
                      const Icon(
                        Icons.snooze,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.multiset.setRest != null
                            ? formatDurationToMinutesSeconds(
                                widget.multiset.setRest)
                            : '0:00',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (hasSpecialInstructions)
                _buildOptionalInfo(
                  title: 'global_special_instructions',
                  content: widget.multiset.specialInstructions,
                  context: context,
                ),
              if (hasObjectives)
                _buildOptionalInfo(
                  title: 'global_objectives',
                  content: widget.multiset.objectives,
                  context: context,
                ),
              if (hasSpecialInstructions || hasObjectives) ...[
                const Divider(),
                const SizedBox(height: 10),
              ],
              if (widget.multiset.trainingExercises != null)
                _buildWidgetExercisesList(widget.multiset.trainingExercises!),
            ],
          ),
        ),
        _buildExerciseRest()
      ],
    );
  }

  Widget _buildWidgetExercisesList(List<TrainingExercise> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final exercise = items[index];
        final isLast = index == items.length - 1;

        return exercise.trainingExerciseType == TrainingExerciseType.run
            ? ActiveMultisetRunWidget(
                multiset: widget.multiset,
                tExercise: exercise,
                isLast: isLast,
                multisetIndex: widget.multisetIndex,
                multisetExerciseIndex: index,
                key: GlobalKey(),
              )
            : ActiveMultisetExerciseWidget(
                multiset: widget.multiset,
                tExercise: exercise,
                isLast: isLast,
                multisetIndex: widget.multisetIndex,
                multisetExerciseIndex: index,
                key: GlobalKey(),
              );
      },
    );
  }

  Row _buildExerciseRest() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.isLast)
          const Icon(
            Icons.snooze,
            size: 20,
          ),
        if (!widget.isLast) const SizedBox(width: 5),
        if (!widget.isLast)
          Text(
            widget.multiset.multisetRest != null
                ? formatDurationToMinutesSeconds(widget.multiset.multisetRest)
                : '0:00',
          ),
      ],
    );
  }
}

Widget _buildOptionalInfo({
  required String title,
  required String? content,
  required BuildContext context,
}) {
  if (content == null || content.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        tr(title),
        style: const TextStyle(color: AppColors.lightBlack),
      ),
      Text(
        content,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.lightBlack,
            ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
