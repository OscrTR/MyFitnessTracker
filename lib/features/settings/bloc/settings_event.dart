part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final bool isReminderActive;

  const UpdateSettings({required this.isReminderActive});

  @override
  List<Object> get props => [isReminderActive];
}
