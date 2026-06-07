import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/lock_screen_page.dart';
import 'features/auth/presentation/pages/setup_password_page.dart';
import 'features/data_management/presentation/pages/data_management_page.dart';
import 'features/patient/presentation/pages/patient_detail_page.dart';
import 'features/patient/presentation/pages/patient_search_page.dart';
import 'injection_container.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/lock',
  refreshListenable: _GoRouterRefreshStream(sl<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = sl<AuthBloc>().state;
    final location = state.matchedLocation;
    final isPublicRoute = location == '/lock' || location == '/setup';

    return switch (authState) {
      AuthAuthenticated() => isPublicRoute ? '/' : null,
      AuthSetupRequired() => location == '/setup' ? null : '/setup',
      AuthLoading() => null,
      _ => location == '/lock' ? null : '/lock',
    };
  },
  routes: [
    GoRoute(path: '/lock', builder: (_, __) => const LockScreenPage()),
    GoRoute(path: '/setup', builder: (_, __) => const SetupPasswordPage()),
    GoRoute(path: '/', builder: (_, __) => const PatientSearchPage()),
    GoRoute(
      path: '/patient/new',
      builder: (_, __) => const PatientDetailPage(patientId: null),
    ),
    GoRoute(
      path: '/patient/:id',
      builder: (_, state) =>
          PatientDetailPage(patientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/data-management',
      builder: (_, __) => const DataManagementPage(),
    ),
  ],
);
