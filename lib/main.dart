import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart';
import 'core/utils/dev_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(const Size(1024, 700));
  await windowManager.setTitle('DentMaster');
  await windowManager.center();
  await windowManager.maximize();

  await initDependencies();
  await seedTestDataIfEmpty();
  sl<AuthBloc>().add(const AuthEvent.checkRequested());
  runApp(const DentMasterApp());
}
