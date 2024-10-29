import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  bool _isDataInitialized = false;
  File? _imageToDelete;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _getImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imgpath = directory.path;
    final String imageOriginalName = path.basename(file.path);
    await file.saveTo('$imgpath/$imageOriginalName');

    setState(() {
      _image = File(file.path);
    });
  }

  Future<void> _deleteCurrentImage() async {
    if (_image != null) {
      setState(() {
        _imageToDelete = _image;
        _image = null;
      });
    }
  }

  Future<void> _deleteImageFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imgpath = directory.path;
    final String imageOriginalName = path.basename(_imageToDelete!.path);
    final String fullPath = '$imgpath/$imageOriginalName';
    final File fileToDelete = File(fullPath);

    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
    }
  }

  Future<void> _changeImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imgpath = directory.path;
    final String imageOriginalName = path.basename(file.path);
    await file.saveTo('$imgpath/$imageOriginalName');

    setState(() {
      _imageToDelete = _image;
      _image = File(file.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
            builder: (context, state) {
          if (state is ExerciseManagementLoaded &&
              state.selectedExercise == null) {
            return const Center(child: Text('Exercise not found.'));
          } else if (state is ExerciseManagementLoaded &&
              state.selectedExercise != null) {
            final selectedExercise = state.selectedExercise;
            if (!_isDataInitialized) {
              _nameController.text = selectedExercise!.name;
              _descriptionController.text = selectedExercise.description ?? '';
              if (selectedExercise.imageName != null &&
                  selectedExercise.imageName!.isNotEmpty) {
                final file = File(selectedExercise.imageName!);
                file.exists().then((exists) {
                  if (exists) {
                    setState(() {
                      _image = file;
                    });
                  }
                });
              }
              _isDataInitialized = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Positioned(
                      child: GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go('/trainings');
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Edit exercise',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Name',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.lightBlack),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _nameController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 10),
                        hintText: 'Enter exercise name here',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.lightBlack),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Image',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.lightBlack),
                      ),
                      if (_image != null)
                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'change') {
                              _changeImage();
                            } else if (value == 'delete') {
                              _deleteCurrentImage();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'change',
                              child: Row(
                                children: [
                                  Text('Change'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _image!,
                          width: MediaQuery.of(context).size.width - 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _getImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColors.lightBlack)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Choose an image',
                                    style:
                                        TextStyle(color: AppColors.lightBlack),
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: AppColors.lightBlack,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Text(
                  'Description',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.lightBlack),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 10),
                        hintText: 'Enter exercise description here',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.lightBlack),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_imageToDelete != null) {
                      _deleteImageFile();
                    }

                    BlocProvider.of<ExerciseManagementBloc>(context).add(
                      UpdateExerciseEvent(
                          id: state.selectedExercise!.id!,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          imageName: _image != null ? _image!.path : ''),
                    );
                    GoRouter.of(context).go('/trainings');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Exercise state error.'));
        }),
      ),
    );
  }
}
