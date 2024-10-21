import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int? id;
  final String name;
  final String imageName;
  final String description;

  const Exercise({
    this.id,
    required this.name,
    required this.imageName,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, imageName, description];
}
