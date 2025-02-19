import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences sharedPreferences;
  SettingsBloc({required this.sharedPreferences}) : super(SettingsInitial()) {
    on<LoadSettings>((event, emit) {
      final isReminderNotificationActive =
          sharedPreferences.getBool('isReminderNotificationActive') ?? false;
      emit(SettingsLoaded(
          isReminderNotificationActive: isReminderNotificationActive));
    });

    on<SetReminderNotificationSettings>((event, emit) async {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        await sharedPreferences.setBool(
            'isReminderNotificationActive', event.isReminderNotificationActive);
        currentState.copyWith(
            isReminderNotificationActive: event.isReminderNotificationActive);
      }
    });
  }
}
