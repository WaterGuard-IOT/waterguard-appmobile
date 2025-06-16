import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waterguard/app/app.dart';
import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/data/repositories/alert_repository_impl.dart';
import 'package:waterguard/data/repositories/tank_repository_impl.dart';
import 'package:waterguard/data/repositories/user_repository_impl.dart';
import 'package:waterguard/data/repositories/user_settings_repository_impl.dart';
import 'package:waterguard/data/repositories/water_quality_repository_impl.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/domain/repositories/user_settings_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';

import 'data/repositories/backend_repositories.dart';
import 'data/services/auth_service.dart';
import 'data/services/http_service.dart';
import 'data/services/tank_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final mockDataProvider = MockDataProvider();
  await mockDataProvider.init();

  //setupDependencies(mockDataProvider);
  setupBackendDependencies();

  runApp(const WaterGuardApp());
}

void setupBackendDependencies() {
  // Servicios HTTP
  getIt.registerSingleton<HttpService>(HttpService());

  getIt.registerSingleton<AuthService>(
    AuthService(getIt<HttpService>()),
  );

  getIt.registerSingleton<TankService>(
    TankService(getIt<HttpService>()),
  );

  // Repositorios que se conectan al backend
  getIt.registerSingleton<UserRepository>(
    BackendUserRepositoryImpl(authService: getIt<AuthService>()),
  );

  getIt.registerSingleton<TankRepository>(
    BackendTankRepositoryImpl(tankService: getIt<TankService>()),
  );

  getIt.registerSingleton<WaterQualityRepository>(
    BackendWaterQualityRepositoryImpl(tankService: getIt<TankService>()),
  );

  getIt.registerSingleton<AlertRepository>(
    BackendAlertRepositoryImpl(),
  );

  // Repositorio de configuraciones (sigue usando SharedPreferences)
  getIt.registerSingleton<UserSettingsRepository>(
    UserSettingsRepositoryImpl(),
  );
}

void setupDependencies(MockDataProvider mockDataProvider) {
  getIt.registerSingleton<MockDataProvider>(mockDataProvider);

  getIt.registerSingleton<TankRepository>(
    TankRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  );

  getIt.registerSingleton<WaterQualityRepository>(
    WaterQualityRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  );

  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  );

  getIt.registerSingleton<AlertRepository>(
    AlertRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  );

  getIt.registerSingleton<UserSettingsRepository>(
    UserSettingsRepositoryImpl(),
  );
}