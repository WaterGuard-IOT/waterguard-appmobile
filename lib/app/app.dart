// lib/app/app.dart - ACTUALIZADO
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:waterguard/app/routes/app_router.dart';
import 'package:waterguard/app/theme/app_theme.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'package:waterguard/data/services/auth_service.dart';
import 'package:waterguard/presentation/blocs/alerts/alerts_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:waterguard/presentation/blocs/theme/theme_bloc.dart';
import 'package:waterguard/presentation/blocs/theme/theme_event.dart';
import 'package:waterguard/presentation/blocs/theme/theme_state.dart';

final GetIt getIt = GetIt.instance;

class WaterGuardApp extends StatelessWidget {
  const WaterGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            userRepository: getIt<UserRepository>(),
            authService: getIt<AuthService>(),
          ),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            tankRepository: getIt<TankRepository>(),
            waterQualityRepository: getIt<WaterQualityRepository>(),
            alertRepository: getIt<AlertRepository>(),
            // --- CORRECCIÓN: Inyectar el TankService requerido ---
            tankService: getIt<TankService>(),
          ),
        ),
        BlocProvider<AlertsBloc>(
          create: (context) => AlertsBloc(
            alertRepository: getIt<AlertRepository>(),
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(LoadThemeMode()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'WaterGuard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.splash,
          );
        },
      ),
    );
  }
}
