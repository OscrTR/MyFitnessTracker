part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isReminderNotificationActive;

  const SettingsLoaded({required this.isReminderNotificationActive});

  SettingsLoaded copyWith({bool? isReminderNotificationActive}) {
    return SettingsLoaded(
        isReminderNotificationActive:
            isReminderNotificationActive ?? this.isReminderNotificationActive);
  }

  @override
  List<Object> get props => [isReminderNotificationActive];
}
