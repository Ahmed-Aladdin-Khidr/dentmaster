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
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
            _searchFocus.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('DentMaster'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_backup_restore),
                tooltip: 'Data Management',
                onPressed: () => context.push('/data-management'),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone… (Ctrl+F)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<PatientListBloc>()
                                  .add(const PatientListEvent.searched(''));
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
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
                    PatientListLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    PatientListSuccess(:final patients) when patients.isEmpty =>
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_search,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No patients yet.\nAdd your first patient with the + button.'
                                  : 'No patients found for "${_searchController.text}".',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    PatientListSuccess(:final patients) => ListView.builder(
                        itemCount: patients.length,
                        itemBuilder: (_, i) => PatientCard(patient: patients[i]),
                      ),
                    PatientListFailure(:final message) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text(message),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/patient/new'),
            tooltip: 'Add Patient',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
