import 'dart:convert';

import 'package:equatable/equatable.dart';

class Multiset extends Equatable {
  final int? id;
  final int? trainingId;
  final int sets;
  final int setRest;
  final int multisetRest;
  final String specialInstructions;
  final String objectives;
  final int? position;
  final String? widgetKey;

  const Multiset({
    this.id,
    this.trainingId,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.specialInstructions,
    required this.objectives,
    this.position,
    this.widgetKey,
  });

  @override
  List<Object?> get props {
    return [
      id,
      trainingId,
      sets,
      setRest,
      multisetRest,
      specialInstructions,
      objectives,
      position,
      widgetKey,
    ];
  }

  Multiset copyWith({
    int? id,
    int? trainingId,
    int? sets,
    int? setRest,
    int? multisetRest,
    String? specialInstructions,
    String? objectives,
    int? position,
    String? widgetKey,
  }) {
    return Multiset(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      sets: sets ?? this.sets,
      setRest: setRest ?? this.setRest,
      multisetRest: multisetRest ?? this.multisetRest,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
      position: position ?? this.position,
      widgetKey: widgetKey ?? this.widgetKey,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'sets': sets,
      'setRest': setRest,
      'multisetRest': multisetRest,
      'specialInstructions': specialInstructions,
      'objectives': objectives,
      'position': position,
      'widgetKey': widgetKey,
    };
  }

  factory Multiset.fromMap(Map<String, dynamic> map) {
    return Multiset(
      id: map['id'] != null ? map['id'] as int : null,
      trainingId: map['trainingId'] != null ? map['trainingId'] as int : null,
      sets: map['sets'] as int,
      setRest: map['setRest'] as int,
      multisetRest: map['multisetRest'] as int,
      specialInstructions: map['specialInstructions'] as String,
      objectives: map['objectives'] as String,
      position: map['position'] != null ? map['position'] as int : null,
      widgetKey: map['widgetKey'] != null ? map['widgetKey'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Multiset.fromJson(String source) =>
      Multiset.fromMap(json.decode(source) as Map<String, dynamic>);
}
