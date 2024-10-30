import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';

class Exercise extends Equatable {
  final int? id;
  final String name;
  final String? imagePath;
  final String? description;

  Exercise({
    this.id,
    required this.name,
    this.imagePath,
    this.description,
  }) {
    if (name.isEmpty) {
      throw ExerciseNameException();
    }
  }

  @override
  List<Object?> get props => [id, name, imagePath, description];
}
