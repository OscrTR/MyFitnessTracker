import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../../../helper_functions.dart';
import '../../../training_management/models/multiset.dart';
import '../../../training_management/models/training_exercise.dart';
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
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.timberwolf),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpandablePanel(
                header: _buildExpandableMultisetHeader(context),
                collapsed: const SizedBox(),
                expanded: widget.multiset.objectives != null &&
                        widget.multiset.objectives != ''
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('global_objectives'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${widget.multiset.objectives}'),
                        ],
                      )
                    : const SizedBox(),
                theme: const ExpandableThemeData(
                  hasIcon: false,
                  tapHeaderToExpand: true,
                ),
              ),
              _buildWidgetExercisesList(widget.multiset.trainingExercises),
            ],
          ),
        ),
        if (!widget.isLast && widget.multiset.multisetRest != 0)
          _buildExerciseRest()
      ],
    );
  }

  Widget _buildExpandableMultisetHeader(BuildContext context) {
    return Builder(builder: (context) {
      final multisetController = ExpandableController.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr('global_multiset'),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.multiset.objectives != null &&
                  widget.multiset.objectives != '')
                Icon(
                  multisetController?.expanded == true
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${widget.multiset.sets} sets'),
          Text(
              '${widget.multiset.setRest != 0 ? formatDurationToMinutesSeconds(widget.multiset.setRest) : '0:00'} ${tr('active_training_rest')}'),
          if (widget.multiset.specialInstructions != null &&
              widget.multiset.specialInstructions != '')
            Text('${widget.multiset.specialInstructions}'),
        ],
      );
    });
  }

  Widget _buildWidgetExercisesList(List<TrainingExercise> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final exercise = items[index];
        final isLast = index == items.length - 1;

        return exercise.type == TrainingExerciseType.run
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

  Widget _buildExerciseRest() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
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
              widget.multiset.multisetRest != 0
                  ? formatDurationToMinutesSeconds(widget.multiset.multisetRest)
                  : '0:00',
            ),
        ],
      ),
    );
  }
}
