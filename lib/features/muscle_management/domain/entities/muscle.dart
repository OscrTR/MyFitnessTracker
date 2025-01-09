import 'package:equatable/equatable.dart';

class Muscle extends Equatable {
  final int? id;
  final String name;
  final String bodyPart;

  const Muscle({
    this.id,
    required this.name,
    required this.bodyPart,
  });

  Muscle copyWith({
    int? id,
    String? name,
    String? bodyPart,
  }) {
    return Muscle(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
    );
  }

  @override
  List<Object?> get props => [id, name, bodyPart];
}
