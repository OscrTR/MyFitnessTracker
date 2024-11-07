import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';

class TrainingDetailsPage extends StatefulWidget {
  final TrainingType trainingType;

  const TrainingDetailsPage({super.key, required this.trainingType});

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Details for ${widget.trainingType}'),
    );
  }
}
