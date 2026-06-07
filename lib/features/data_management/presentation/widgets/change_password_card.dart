import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/widgets/password_field.dart';

class ChangePasswordCard extends StatelessWidget {
  const ChangePasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline,
                    color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 12),
                Text('Change Password',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Update the application password used to protect patient data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.password),
              label: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const _ChangePasswordDialog(),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final current = _currentCtrl.text;
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _localError = 'All fields are required.');
      return;
    }
    if (newPass.length < 4) {
      setState(() => _localError = 'New password must be at least 4 characters.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _localError = 'New passwords do not match.');
      return;
    }
    setState(() => _localError = null);
    context
        .read<AuthBloc>()
        .add(AuthEvent.changePasswordSubmitted(current, newPass));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev is AuthLoading,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully.')),
          );
        } else if (state is AuthFailure) {
          setState(() => _localError = state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return AlertDialog(
          title: const Text('Change Password'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PasswordField(
                  controller: _currentCtrl,
                  labelText: 'Current Password',
                  onSubmitted: (_) {},
                ),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _newCtrl,
                  labelText: 'New Password',
                  onSubmitted: (_) {},
                ),
                const SizedBox(height: 12),
                PasswordField(
                  controller: _confirmCtrl,
                  labelText: 'Confirm New Password',
                  errorText: _localError,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
