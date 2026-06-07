import 'package:go_router/go_router.dart';
import 'features/patient/presentation/pages/patient_search_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PatientSearchPage(),
    ),
    // Phase 4: patient search
    // Phase 5: patient detail
    // Phase 8: data management
    // Phase 9: lock screen
  ],
);
