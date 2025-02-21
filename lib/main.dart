import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/database/database_service.dart';

import 'app_theme.dart';

import 'core/messages/bloc/message_bloc.dart';
import 'features/active_training/bloc/active_training_bloc.dart';
import 'features/base_exercise_management/bloc/base_exercise_management_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/training_history/bloc/training_history_bloc.dart';
import 'features/training_management/bloc/training_management_bloc.dart';
import 'injection_container.dart' as di;
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();
  FlutterForegroundTask.initCommunicationPort();
  await di.sl<DatabaseService>().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: null,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<MessageBloc>(
          create: (_) => di.sl<MessageBloc>(),
          lazy: false,
        ),
        BlocProvider<BaseExerciseManagementBloc>(
          create: (_) => di.sl<BaseExerciseManagementBloc>()
            ..add(GetAllBaseExercisesEvent()),
          lazy: false,
        ),
        BlocProvider<TrainingManagementBloc>(
          create: (_) =>
              di.sl<TrainingManagementBloc>()..add(FetchTrainingsEvent()),
          lazy: false,
        ),
        BlocProvider<ActiveTrainingBloc>(
          create: (_) =>
              di.sl<ActiveTrainingBloc>()..add(LoadDefaultActiveTraining()),
          lazy: false,
        ),
        BlocProvider<TrainingHistoryBloc>(
          create: (_) =>
              di.sl<TrainingHistoryBloc>()..add(FetchHistoryEntriesEvent()),
          lazy: false,
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(LoadSettings()),
          lazy: false,
        )
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
