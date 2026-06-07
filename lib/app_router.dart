import 'package:go_router/go_router.dart';
import 'features/data_management/presentation/pages/data_management_page.dart';
import 'features/patient/presentation/pages/patient_detail_page.dart';
import 'features/patient/presentation/pages/patient_search_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const PatientSearchPage(),
    ),
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
    // Phase 9: lock screen
    // Phase 9: setup password screen
  ],
);
