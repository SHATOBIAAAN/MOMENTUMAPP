import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/di.dart';
import 'core/theme_provider.dart';
import 'core/app_state_provider.dart';
import 'core/router.dart';
import 'presentation/themes/dark_theme.dart';
import 'presentation/themes/light_theme.dart';
import 'data/services/notification_service.dart';
import 'data/services/github_sync_service.dart';

/// Main entry point of the Momentum app
/// Initializes dependencies and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection and Isar database
  await DI.init();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Initialize app state provider
  final appStateProvider = AppStateProvider();
  await appStateProvider.initialize();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize(
    onNotificationTapped: (payload) {
      debugPrint('Notification tapped with payload: $payload');
      // Handle notification tap - navigate to task details
      if (payload != null && payload.startsWith('task_')) {
        final taskId = int.tryParse(payload.split('_')[1]);
        if (taskId != null) {
          // Navigate to task details
          debugPrint('Navigate to task: $taskId');
        }
      }
    },
  );

  // Initialize GitHub Sync Service
  final githubSyncService = GitHubSyncService();
  await githubSyncService.initialize(
    taskRepository: DI.taskRepository,
    workspaceRepository: DI.workspaceRepository,
    tagRepository: DI.tagRepository,
    enableAutoSync: true,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      child: MomentumApp(
        themeProvider: themeProvider,
        appStateProvider: appStateProvider,
        githubSyncService: githubSyncService,
      ),
    ),
  );
}

/// Root widget of the application
class MomentumApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AppStateProvider appStateProvider;
  final GitHubSyncService githubSyncService;

  const MomentumApp({
    super.key,
    required this.themeProvider,
    required this.appStateProvider,
    required this.githubSyncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: appStateProvider),
        Provider.value(value: githubSyncService),
      ],
             child: MultiBlocProvider(
               providers: [
                 BlocProvider(create: (context) => DI.createTaskBloc()),
                 BlocProvider(create: (context) => DI.createWorkspaceBloc()),
                 BlocProvider(create: (context) => DI.createTagBloc()),
               ],
               child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp.router(
              title: 'Momentum',
              debugShowCheckedModeBanner: false,

              // Localization
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,

              // Theme configuration
              theme: lightTheme(),
              darkTheme: darkTheme(),
              themeMode: themeProvider.themeMode,

              // Router
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
