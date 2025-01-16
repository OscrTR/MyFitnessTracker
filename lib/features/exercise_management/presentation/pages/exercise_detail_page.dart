import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/exercise.dart';
import '../bloc/exercise_management_bloc.dart';
import '../widgets/exercise_detail_back_app_bar_widget.dart';
import '../widgets/exercise_detail_custom_text_field_widget.dart';
import '../widgets/exercise_detail_image_picker_widget.dart';

class ExerciseDetailPage extends StatefulWidget {
  final bool fromTrainingCreation;
  const ExerciseDetailPage({super.key, required this.fromTrainingCreation});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  bool _isDataInitialized = false;
  File? _imageToDelete;
  final List<ExerciseType> _exerciseType = [
    ExerciseType.workout,
    ExerciseType.yoga
  ];
  late ExerciseType _selectedExerciseType;
  List<MuscleGroup> _selectedMuscleGroups = [];

  @override
  void initState() {
    _initType();
    super.initState();
  }

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

  void _initType() {
    final exercise =
        (sl<ExerciseManagementBloc>().state as ExerciseManagementLoaded)
            .selectedExercise;
    _selectedExerciseType = exercise?.exerciseType ?? ExerciseType.workout;
    if (exercise != null) {
      _selectedMuscleGroups = exercise.muscleGroups ?? [];
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
                    widget.fromTrainingCreation
                        ? GoRouter.of(context).push('/training_detail')
                        : GoRouter.of(context).push('/trainings');
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
                CustomDropdown<ExerciseType>(
                  items: _exerciseType,
                  initialItem: _selectedExerciseType,
                  decoration: CustomDropdownDecoration(
                    listItemStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.lightBlack),
                    headerStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.black),
                    closedSuffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.lightBlack,
                    ),
                    expandedSuffixIcon: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 20,
                      color: AppColors.lightBlack,
                    ),
                    closedBorder: Border.all(color: AppColors.lightBlack),
                    expandedBorder: Border.all(color: AppColors.lightBlack),
                  ),
                  headerBuilder: (context, selectedItem, enabled) {
                    return Text(
                        selectedItem.translate(context.locale.languageCode));
                  },
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    return Text(item.translate(context.locale.languageCode));
                  },
                  onChanged: (value) {
                    _selectedExerciseType = value!;
                  },
                ),
                const SizedBox(height: 30),
                MultiSelectDialogField<MuscleGroup>(
                  initialValue: _selectedMuscleGroups,
                  items: MuscleGroup.values
                      .map((e) => MultiSelectItem(e, e.name))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  onConfirm: (values) {
                    _selectedMuscleGroups = values;
                  },
                ),
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
                    context.read<ExerciseManagementBloc>().add(
                          CreateOrUpdateExerciseEvent(
                            Exercise(
                              id: exercise?.id,
                              name: _nameController.text,
                              description: _descriptionController.text,
                              imagePath: _image?.path ?? '',
                              exerciseType: _selectedExerciseType,
                              muscleGroups: _selectedMuscleGroups,
                            ),
                          ),
                        );
                    widget.fromTrainingCreation
                        ? GoRouter.of(context).push('/training_detail')
                        : GoRouter.of(context).push('/trainings');
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
