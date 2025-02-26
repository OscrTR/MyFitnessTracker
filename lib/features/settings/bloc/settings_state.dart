part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isReminderActive;

  const SettingsLoaded({required this.isReminderActive});

  SettingsLoaded copyWith({
    bool? isReminderActive,
  }) {
    return SettingsLoaded(
      isReminderActive: isReminderActive ?? this.isReminderActive,
    );
  }

  @override
  List<Object> get props => [isReminderActive];
}
