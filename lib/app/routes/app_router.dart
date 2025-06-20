// lib/app/routes/app_router.dart (corregido)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:waterguard/presentation/screens/auth/login_screen.dart';
import 'package:waterguard/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:waterguard/presentation/screens/splash/splash_screen.dart';
import 'package:waterguard/presentation/screens/tank_detail/tank_detail_screen.dart';
import 'package:waterguard/presentation/screens/alerts/alerts_screen.dart';
import 'package:waterguard/presentation/screens/settings/settings_screen.dart';
import 'package:waterguard/presentation/screens/add_tank/add_tank_screen.dart';
import 'package:waterguard/presentation/blocs/tank/tank_bloc.dart';
import 'package:waterguard/presentation/blocs/settings/settings_bloc.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_state.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'package:waterguard/domain/repositories/user_settings_repository.dart';
import 'package:waterguard/data/services/tank_service.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String tankDetail = '/tank-detail';
  static const String alerts = '/alerts';
  static const String settings = '/settings';
  static const String addTank = '/add-tank';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final getIt = GetIt.instance;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/tank-detail':
        final tankId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => TankBloc(
              tankRepository: getIt<TankRepository>(),
              waterQualityRepository: getIt<WaterQualityRepository>(),
            ),
            child: TankDetailScreen(tankId: tankId),
          ),
        );

      case '/alerts':
        return MaterialPageRoute(builder: (_) => const AlertsScreen());

      case '/add-tank':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => AddTankBloc(
              tankService: getIt<TankService>(),
            ),
            child: const AddTankScreen(),
          ),
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthAuthenticated ? authState.userId : 'default';

            return BlocProvider(
              create: (context) => SettingsBloc(
                userSettingsRepository: getIt<UserSettingsRepository>(),
                userId: userId,
              ),
              child: const SettingsScreen(),
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}