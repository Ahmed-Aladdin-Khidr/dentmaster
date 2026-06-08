import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../bloc/patient_list/patient_list_bloc.dart';
import '../bloc/patient_list/patient_list_event.dart';
import '../bloc/patient_list/patient_list_state.dart';
import '../widgets/patient_card.dart';

class PatientSearchPage extends StatelessWidget {
  const PatientSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PatientListBloc>()..add(const PatientListEvent.started()),
      child: const _PatientSearchView(),
    );
  }
}

class _PatientSearchView extends StatefulWidget {
  const _PatientSearchView();

  @override
  State<_PatientSearchView> createState() => _PatientSearchViewState();
}

class _PatientSearchViewState extends State<_PatientSearchView> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      _searchFocus.requestFocus();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.f5) {
      _refresh(context);
      return true;
    }
    return false;
  }

  void _refresh(BuildContext context) {
    _searchController.clear();
    context.read<PatientListBloc>().add(const PatientListEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.white,
            title: const Text('DentMaster',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh (F5)',
                onPressed: () => _refresh(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings_backup_restore,
                    color: Colors.white),
                tooltip: 'Data Management',
                onPressed: () => context.push('/data-management'),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.45)),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone… (Ctrl+F)',
                          hintStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<PatientListBloc>()
                                        .add(const PatientListEvent.searched(''));
                                  },
                                )
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                        ),
                        onChanged: (query) => context
                            .read<PatientListBloc>()
                            .add(PatientListEvent.searched(query)),
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<PatientListBloc, PatientListState>(
                        builder: (context, state) => switch (state) {
                          PatientListInitial() => const SizedBox.shrink(),
                          PatientListLoading() => const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white)),
                          PatientListSuccess(:final patients)
                              when patients.isEmpty =>
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_search,
                                      size: 64, color: Colors.white54),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'No patients yet.\nAdd your first patient with the + button.'
                                        : 'No patients found for "${_searchController.text}".',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          PatientListSuccess(:final patients) =>
                            ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: patients.length,
                              itemBuilder: (_, i) =>
                                  PatientCard(patient: patients[i]),
                            ),
                          PatientListFailure(:final message) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 48, color: Colors.redAccent),
                                  const SizedBox(height: 12),
                                  Text(message,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<PatientListBloc>()
                                        .add(const PatientListEvent.started()),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/patient/new'),
            tooltip: 'Add Patient',
            child: const Icon(Icons.add),
          ),
        );
  }
}
