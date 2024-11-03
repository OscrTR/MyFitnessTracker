import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int? id;
  final String name;
  final String? imagePath;
  final String? description;

  const Exercise({
    this.id,
    required this.name,
    this.imagePath,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, imagePath, description];
}
