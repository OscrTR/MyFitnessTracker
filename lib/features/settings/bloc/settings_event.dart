part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SetReminderNotificationSettings extends SettingsEvent {
  final bool isReminderNotificationActive;

  const SetReminderNotificationSettings(
      {required this.isReminderNotificationActive});

  @override
  List<Object> get props => [isReminderNotificationActive];
}
