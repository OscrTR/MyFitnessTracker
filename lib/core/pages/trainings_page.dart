import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/pages/exercise_page.dart';

class TrainingsPage extends StatelessWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExercisePage(),
    );
  }
}
