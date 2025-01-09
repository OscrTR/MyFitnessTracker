import '../../domain/entities/muscle.dart';

class MuscleModel extends Muscle {
  const MuscleModel({
    super.id,
    required super.name,
    required super.bodyPart,
  });

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(
      id: json['id'],
      name: json['name'] as String,
      bodyPart: json['body_part'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'body_part': bodyPart,
    };
  }

  factory MuscleModel.fromMuscle(Muscle muscle) {
    return MuscleModel(
        id: muscle.id, name: muscle.name, bodyPart: muscle.bodyPart);
  }

  @override
  MuscleModel copyWith({int? id, String? name, String? bodyPart}) {
    return MuscleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
    );
  }
}
