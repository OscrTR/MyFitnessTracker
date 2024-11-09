import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../assets/app_colors.dart';
import '../../domain/entities/training.dart';

class TrainingTypeSelectionWidget extends StatelessWidget {
  final TrainingType selectedTrainingType;
  final ValueChanged<TrainingType> onTypeSelected;

  const TrainingTypeSelectionWidget(
      {super.key,
      required this.selectedTrainingType,
      required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('training_detail_page_training_type'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.lightBlack),
        ),
        GestureDetector(
          onTapDown: (details) async {
            final selected = await showMenu<TrainingType>(
              context: context,
              position: RelativeRect.fromLTRB(
                details.globalPosition.dx,
                details.globalPosition.dy,
                details.globalPosition.dx,
                details.globalPosition.dy,
              ),
              items: TrainingType.values
                  .map((type) => PopupMenuItem(
                        value: type,
                        child: Text(context.tr('global_${type.name}')),
                      ))
                  .toList(),
            );

            if (selected != null) onTypeSelected(selected);
          },
          child: Row(
            children: [
              Text(
                context.tr('global_${selectedTrainingType.name}'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.lightBlack,
                size: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
