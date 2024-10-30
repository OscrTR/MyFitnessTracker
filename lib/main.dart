import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/app_theme.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/router.dart';
import 'features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'injection_container.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'lib/assets/translations',
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
      providers: [
        BlocProvider<MessageBloc>(
            create: (BuildContext context) => sl<MessageBloc>()),
        BlocProvider<ExerciseManagementBloc>(
          create: (BuildContext context) =>
              sl<ExerciseManagementBloc>()..add(FetchExercisesEvent()),
        ),
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
