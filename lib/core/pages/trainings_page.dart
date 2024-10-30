import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/pages/exercise_page.dart';

class TrainingsPage extends StatelessWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trainings',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showNewDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: Text('New',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.white)),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Expanded(child: ExercisePage()),
          ],
        ),
      ),
    );
  }
}

void _showNewDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text('Add new'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go('/exercise_detail');
              Navigator.pop(context, 'New exercise');
            },
            child: const SizedBox(
              child: Text('Exercise'),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
