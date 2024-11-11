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

  Exercise copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? description,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, imagePath, description];
}
