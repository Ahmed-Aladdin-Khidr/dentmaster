import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart';
import 'core/utils/dev_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await seedTestDataIfEmpty();
  sl<AuthBloc>().add(const AuthEvent.checkRequested());
  runApp(const DentMasterApp());
}
