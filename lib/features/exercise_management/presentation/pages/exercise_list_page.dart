import 'package:flutter/material.dart';

import '../widgets/exercise_list_header_widget.dart';
import '../widgets/exercise_list_widget.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          ExerciseListHeader(),
          SizedBox(height: 10),
          Expanded(child: ExerciseList()),
        ],
      ),
    );
  }
}
