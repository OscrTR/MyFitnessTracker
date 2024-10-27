import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'features/exercise_management/presentation/pages/exercise_page.dart';
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
      child: MaterialApp(
        title: 'Exercise',
        theme: ThemeData(
          primaryColor: Colors.green,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const ExercisePage(),
      ),
    );
  }
}
