import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_container.dart';
import 'core/utils/dev_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await seedTestDataIfEmpty();
  runApp(const DentMasterApp());
}
