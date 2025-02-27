part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isReminderActive;
  final List<Log> logs;

  const SettingsLoaded({required this.isReminderActive, this.logs = const []});

  SettingsLoaded copyWith({
    bool? isReminderActive,
    List<Log>? logs,
  }) {
    return SettingsLoaded(
      isReminderActive: isReminderActive ?? this.isReminderActive,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object> get props => [isReminderActive, logs];
}
