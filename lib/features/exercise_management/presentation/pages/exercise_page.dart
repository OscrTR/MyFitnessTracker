import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import '../bloc/exercise_management_bloc.dart';

// TODO : create the real exercise management page
// TODO : move the widgets to widgets
class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocListener<MessageBloc, MessageState>(
          listener: (context, state) {
            if (state is MessageLoaded) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: state.isError ? Colors.red : Colors.green,
                ),
              );
            }
          },
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.lightGrey),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.list,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Exercises',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(child: ExerciseList()),
              ExerciseForm(
                onSubmit: (name, imageName, description) {
                  BlocProvider.of<ExerciseManagementBloc>(context).add(
                    CreateExerciseEvent(
                      name: name,
                      imageName: imageName,
                      description: description,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseList extends StatelessWidget {
  const ExerciseList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
      builder: (context, state) {
        if (state is ExerciseManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExerciseManagementLoaded) {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            itemCount: state.exercises.length,
            itemBuilder: (context, index) {
              final exercise = state.exercises[index];
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 10, right: 0),
                  title: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        BlocProvider.of<ExerciseManagementBloc>(context)
                            .add(GetExerciseEvent(exercise.id!));
                        GoRouter.of(context).go('/exercise_detail');
                      } else if (value == 'delete') {
                        // Trigger delete event
                        BlocProvider.of<ExerciseManagementBloc>(context)
                            .add(DeleteExerciseEvent(exercise.id!));
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.lightBlack,
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is ExerciseManagementFailure) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ExerciseForm extends StatefulWidget {
  final void Function(String name, String imageName, String description)
      onSubmit;

  const ExerciseForm({super.key, required this.onSubmit});

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
      widget.onSubmit(
        _nameController.text,
        _imageNameController.text,
        _descriptionController.text,
      );
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            TextFormField(
              controller: _imageNameController,
              decoration: const InputDecoration(labelText: 'Image Name'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16.0),
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
