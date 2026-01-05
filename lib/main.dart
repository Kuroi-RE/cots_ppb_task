import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/route_names.dart';
import 'core/design_system/colors.dart';
import 'features/tasks/data/models/task.dart';
import 'features/tasks/presentation/pages/dashboard_page.dart';
import 'features/tasks/presentation/pages/task_list_page.dart';
import 'features/tasks/presentation/pages/task_detail_page.dart';
import 'features/tasks/presentation/pages/task_add_page.dart';
import 'features/tasks/state/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: RouteNames.dashboard,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case RouteNames.dashboard:
              return MaterialPageRoute(builder: (_) => const DashboardPage());
            case RouteNames.taskList:
              return MaterialPageRoute(builder: (_) => const TaskListPage());
            case RouteNames.taskDetail:
              final task = settings.arguments as Task;
              return MaterialPageRoute(
                builder: (_) => TaskDetailPage(task: task),
              );
            case RouteNames.addTask:
              return MaterialPageRoute(builder: (_) => const TaskAddPage());
            default:
              return MaterialPageRoute(builder: (_) => const DashboardPage());
          }
        },
      ),
    );
  }
}
