import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/helper_functions.dart';
import '../../../core/enums/enums.dart';
import '../../../core/messages/models/log.dart';
import '../../../core/database/database_service.dart';

import '../../../core/notification_service.dart';
import '../../../injection_container.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>((event, emit) async {
      final preferences = await sl<DatabaseService>().getPreferences();
      if (preferences != null) {
        final bool isReminderActive = preferences['isReminderActive'] ?? true;
        emit(SettingsLoaded(isReminderActive: isReminderActive));
      } else {
        await sl<DatabaseService>().savePreferences(true);
        emit(SettingsLoaded(isReminderActive: true));
      }
      add(GetLogs());
    });

    on<CreateLog>((event, emit) async {
      if (state is! SettingsLoaded) return;
      await sl<DatabaseService>().createLog(event.log);

      add(GetLogs());
    });

    on<GetLogs>((event, emit) async {
      if (state is! SettingsLoaded) return;
      final logs = await sl<DatabaseService>().getAllLogs();
      final currentState = state as SettingsLoaded;

      emit(currentState.copyWith(logs: logs));
    });

    on<UpdateSettings>((event, emit) async {
      if (state is! SettingsLoaded) return;
      final currentState = state as SettingsLoaded;
      final isReminderActive = event.isReminderActive;

      await sl<DatabaseService>().savePreferences(isReminderActive);

      if (!isReminderActive) {
        final reminders = await sl<DatabaseService>().getAllReminders();
        for (var reminder in reminders) {
          await sl<DatabaseService>().deleteReminder(reminder.notificationId);
          await NotificationService.deleteNotification(reminder.notificationId);
        }
      } else {
        final reminders = await sl<DatabaseService>().getAllReminders();
        final trainings = await sl<DatabaseService>().getAllTrainings();

        final trainingDays = <TrainingDay>{};
        for (final training in trainings) {
          for (final trainingDay in training.trainingDays) {
            trainingDays.add(trainingDay);
          }
        }

        // Supprimer tous les reminders et notifications
        for (var reminder in reminders) {
          await sl<DatabaseService>().deleteReminder(reminder.notificationId);
          await NotificationService.deleteNotification(reminder.notificationId);
        }

        // Créer des reminders pour les jours manquants
        for (final day in trainingDays) {
          final int notificationId = NotificationIdGenerator.getNextId();
          NotificationService.scheduleWeeklyNotification(
              day: day, notificationId: notificationId);
        }
      }

      emit(currentState.copyWith(isReminderActive: isReminderActive));
    });
  }
}
