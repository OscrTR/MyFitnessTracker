import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/muscle_management/presentation/bloc/muscle_management_bloc.dart';

class MuscleDetailPage extends StatefulWidget {
  final bool fromExerciseCreation;
  const MuscleDetailPage({super.key, required this.fromExerciseCreation});

  @override
  State<MuscleDetailPage> createState() => _MuscleDetailPageState();
}

class _MuscleDetailPageState extends State<MuscleDetailPage> {
  final _nameController = TextEditingController();
  final _bodyPartController = TextEditingController();
  bool _isDataInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bodyPartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<MuscleManagementBloc, MuscleManagementState>(
        builder: (context, state) {
          if (state is MuscleManagementLoaded) {
            final muscle = state.selectedMuscle;

            if (muscle != null && !_isDataInitialized) {
              _nameController.text = muscle.name;
              _bodyPartController.text = muscle.bodyPart;
              _isDataInitialized = true;
            }
            return Text('data');
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
