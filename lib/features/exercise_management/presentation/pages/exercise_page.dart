import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/exercise_management_bloc.dart';

import '../../../../injection_container.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<ExerciseManagementBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => sl<ExerciseManagementBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: const Placeholder(),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  const ExerciseCreation(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseCreation extends StatefulWidget {
  const ExerciseCreation({super.key});

  @override
  State<ExerciseCreation> createState() => _ExerciseCreationState();
}

String exerciseName = '';
String exerciseImageName = '';
String exerciseDescription = '';

final exerciseNameController = TextEditingController();
final exerciseImageNameController = TextEditingController();
final exerciseDescriptionController = TextEditingController();

class _ExerciseCreationState extends State<ExerciseCreation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: exerciseNameController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Exercise name'),
          onChanged: (value) {
            exerciseName = value;
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: exerciseImageNameController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Exercise image name'),
          onChanged: (value) {
            exerciseImageName = value;
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: exerciseDescriptionController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Exercise description'),
          onChanged: (value) {
            exerciseDescription = value;
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: createExercise, child: const Text('Create exercise'))
      ],
    );
  }

  void createExercise() {
    exerciseNameController.clear();
    exerciseImageNameController.clear();
    exerciseDescriptionController.clear();
    BlocProvider.of<ExerciseManagementBloc>(context).add(CreateExerciseEvent(
        name: exerciseName,
        description: exerciseDescription,
        imageName: exerciseImageName));
    exerciseName = '';
    exerciseImageName = '';
    exerciseDescription = '';
  }
}
