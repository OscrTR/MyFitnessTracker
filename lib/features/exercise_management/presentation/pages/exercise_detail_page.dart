import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_colors.dart';
import '../bloc/exercise_management_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../widgets/exercise_detail_back_app_bar_widget.dart';
import '../widgets/exercise_detail_custom_text_field_widget.dart';
import '../widgets/exercise_detail_image_picker_widget.dart';

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

  void _pickImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imgpath = directory.path;
    final String imageOriginalName = path.basename(file.path);
    await file.saveTo('$imgpath/$imageOriginalName');

    setState(() {
      if (_image != null) {
        _imageToDelete = _image;
      }
      _image = File(file.path);
    });
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
            builder: (context, state) {
          if (state is ExerciseManagementLoaded) {
            final exercise = state.selectedExercise;

            if (exercise != null && !_isDataInitialized) {
              _nameController.text = exercise.name;
              _descriptionController.text = exercise.description ?? '';
              _image = exercise.imagePath != null && exercise.imagePath != ''
                  ? File(exercise.imagePath!)
                  : null;
              _isDataInitialized = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackAppBar(
                  title: context.tr(exercise == null
                      ? 'exercise_detail_page_title_create'
                      : 'exercise_detail_page_title_edit'),
                  onBack: () {
                    GoRouter.of(context).go('/trainings');
                    BlocProvider.of<ExerciseManagementBloc>(context)
                        .add(const ClearSelectedExerciseEvent());
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _nameController,
                  hintText: context.tr('exercise_detail_page_name_hint'),
                ),
                const SizedBox(height: 30),
                ImagePickerWidget(
                  image: _image,
                  onAddImage: _pickImage,
                  onChangeImage: _pickImage,
                  onDeleteImage: () {
                    setState(() {
                      _imageToDelete = _image;
                      _image = null;
                    });
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: context.tr('exercise_detail_page_description_hint'),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    if (_imageToDelete != null) {
                      _deleteImageFile();
                    }

                    final event = exercise == null
                        ? CreateExerciseEvent(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            imagePath: _image?.path ?? '')
                        : UpdateExerciseEvent(
                            id: exercise.id!,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            imagePath: _image?.path ?? '');
                    BlocProvider.of<ExerciseManagementBloc>(context).add(event);
                    GoRouter.of(context).go('/trainings');
                    BlocProvider.of<ExerciseManagementBloc>(context)
                        .add(const ClearSelectedExerciseEvent());
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
                          context.tr('global_save'),
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
          return Center(child: Text(context.tr('error_state')));
        }),
      ),
    );
  }
}
