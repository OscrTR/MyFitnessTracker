import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../app_colors.dart';
import '../../../../core/widgets/custom_text_field_widget.dart';
import '../../../../injection_container.dart';
import '../../models/exercise.dart';
import '../bloc/exercise_management_bloc.dart';
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
  late ExerciseType _selectedExerciseType;
  Map<MuscleGroup, bool> _selectedMuscleGroups = {};

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
    _selectedExerciseType = exercise?.type ?? ExerciseType.workout;

    // Réinitialiser la map avant de la remplir
    _selectedMuscleGroups = {}; // Ou créez une nouvelle map

    if (exercise != null) {
      // Remplir avec tous les muscle groups en une fois
      _selectedMuscleGroups = Map.fromEntries(MuscleGroup.values.map(
          (muscleGroup) => MapEntry(muscleGroup,
              exercise.muscleGroups?.contains(muscleGroup) ?? false)));
    } else {
      // Initialiser tous à false en une fois
      _selectedMuscleGroups = Map.fromEntries(MuscleGroup.values
          .map((muscleGroup) => MapEntry(muscleGroup, false)));
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
    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
                builder: (context, state) {
              if (state is ExerciseManagementLoaded) {
                final exercise = state.selectedExercise;

                if (exercise != null && !_isDataInitialized) {
                  _nameController.text = exercise.name;
                  _descriptionController.text = exercise.description ?? '';
                  _image =
                      exercise.imagePath != null && exercise.imagePath != ''
                          ? File(exercise.imagePath!)
                          : null;
                  _isDataInitialized = true;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, exercise),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _nameController,
                      hintText: context.tr('exercise_detail_page_name_hint'),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText:
                          context.tr('exercise_detail_page_description_hint'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr('exercise_detail_page_type'),
                      style: const TextStyle(color: AppColors.taupeGray),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown<ExerciseType>(
                      items: ExerciseType.values,
                      initialItem: _selectedExerciseType,
                      decoration: CustomDropdownDecoration(
                        listItemStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.timberwolf),
                        headerStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.licorice),
                        closedSuffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.timberwolf,
                        ),
                        expandedSuffixIcon: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: AppColors.timberwolf,
                        ),
                        closedBorder: Border.all(color: AppColors.timberwolf),
                        expandedBorder: Border.all(color: AppColors.timberwolf),
                      ),
                      headerBuilder: (context, selectedItem, enabled) {
                        return Text(selectedItem
                            .translate(context.locale.languageCode));
                      },
                      listItemBuilder:
                          (context, item, isSelected, onItemSelect) {
                        return Text(
                            item.translate(context.locale.languageCode));
                      },
                      onChanged: (value) {
                        _selectedExerciseType = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    _buildMuscleGroups(context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('exercise_detail_page_image'),
                          style: const TextStyle(color: AppColors.taupeGray),
                        ),
                        if (_image == null)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.timberwolf),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                tr('global_select'),
                                style:
                                    const TextStyle(color: AppColors.taupeGray),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 70)
                  ],
                );
              }
              return Center(child: Text(context.tr('error_state')));
            }),
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.floralWhite,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 70,
              child: GestureDetector(
                onTap: () {
                  if (_imageToDelete != null) {
                    _deleteImageFile();
                  }
                  context.read<ExerciseManagementBloc>().add(
                        CreateOrUpdateExerciseEvent(
                          Exercise.create(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            imagePath: _image?.path ?? '',
                            type: _selectedExerciseType,
                            muscleGroups: _selectedMuscleGroups.entries
                                .where((el) => el.value == true)
                                .map((el) => el.key)
                                .toList(),
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
                      color: AppColors.folly,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: Text(
                      tr('global_save'),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ))
      ]),
    );
  }

  Column _buildMuscleGroups(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('exercise_detail_page_muscles'),
              style: const TextStyle(color: AppColors.taupeGray),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => StatefulBuilder(
                    builder: (context, setDialogState) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(tr('global_select')),
                      content: Wrap(
                        spacing: 4,
                        children: _selectedMuscleGroups.keys
                            .map(
                              (e) => FilterChip(
                                side: BorderSide(
                                    color: _selectedMuscleGroups[e]!
                                        ? AppColors.white
                                        : AppColors.timberwolf),
                                label: Text(
                                  e.translate(context.locale.languageCode),
                                ),
                                labelStyle: TextStyle(
                                  color: _selectedMuscleGroups[e]!
                                      ? AppColors.white
                                      : AppColors.taupeGray,
                                ),
                                showCheckmark: true,
                                selectedColor: AppColors.taupeGray,
                                checkmarkColor: AppColors.white,
                                selected: _selectedMuscleGroups[e]!,
                                onSelected: (bool value) {
                                  setDialogState(() {
                                    _selectedMuscleGroups[e] = value;
                                  });
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: Text(tr('global_cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.timberwolf),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  tr('global_select'),
                  style: const TextStyle(color: AppColors.taupeGray),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: [
            ..._selectedMuscleGroups.entries
                .where((entry) => entry.value == true)
                .map(
                  (entry) => FilterChip(
                    side: BorderSide(
                        color: _selectedMuscleGroups[entry.key]!
                            ? AppColors.white
                            : AppColors.timberwolf),
                    label: Text(
                      entry.key.translate(context.locale.languageCode),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedMuscleGroups[entry.key]!
                          ? AppColors.white
                          : AppColors.taupeGray,
                    ),
                    showCheckmark: true,
                    selectedColor: AppColors.taupeGray,
                    checkmarkColor: AppColors.white,
                    selected: _selectedMuscleGroups[entry.key]!,
                    onSelected: (bool value) {
                      setState(() {
                        _selectedMuscleGroups[entry.key] = value;
                      });
                    },
                  ),
                ),
          ],
        ),
      ],
    );
  }

  SizedBox _buildHeader(BuildContext context, Exercise? exercise) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                widget.fromTrainingCreation
                    ? GoRouter.of(context).push('/training_detail')
                    : GoRouter.of(context).push('/trainings');
                BlocProvider.of<ExerciseManagementBloc>(context)
                    .add(const ClearSelectedExerciseEvent());
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.licorice,
              ),
            ),
          ),
          Center(
            child: Text(
              context.tr(exercise == null
                  ? 'exercise_detail_page_title_create'
                  : 'exercise_detail_page_title_edit'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (exercise != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  sl<ExerciseManagementBloc>()
                      .add(DeleteExerciseEvent(exercise.id));
                  GoRouter.of(context).push('/trainings');
                },
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.licorice,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
