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
              BlocListener<ExerciseManagementBloc, ExerciseManagementState>(
                listener: (context, state) {
                  if (state is ExerciseManagementFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ExerciseManagementSuccess) {
                    // Show success message in a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Exercise "${state.exercise.name}" created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: const Placeholder(),
                ),
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  ExerciseForm(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseForm extends StatefulWidget {
  const ExerciseForm({super.key});

  @override
  ExerciseFormState createState() => ExerciseFormState();
}

class ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _imageNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Trigger the CreateExerciseEvent with form data
      BlocProvider.of<ExerciseManagementBloc>(context).add(
        CreateExerciseEvent(
          name: _nameController.text,
          imageName: _imageNameController.text,
          description: _descriptionController.text,
        ),
      );

      // Clear the text fields after submission
      _nameController.clear();
      _imageNameController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),

            // Image Name Field
            TextFormField(
              controller: _imageNameController,
              decoration: const InputDecoration(labelText: 'Image Name'),
            ),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            const SizedBox(height: 16.0),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Create Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
