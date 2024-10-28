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
  await di.init();
  runApp(const MyApp());
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
          theme: appTheme),
    );
  }
}
