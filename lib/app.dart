import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection_container.dart';

class DentMasterApp extends StatelessWidget {
  const DentMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'DentMaster',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
      ),
    );
  }
}
