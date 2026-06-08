import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/password_field.dart';

class SetupPasswordPage extends StatefulWidget {
  const SetupPasswordPage({super.key});

  @override
  State<SetupPasswordPage> createState() => _SetupPasswordPageState();
}

class _SetupPasswordPageState extends State<SetupPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  String? _validationError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 4) {
      setState(() =>
          _validationError = 'Password must be at least 4 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _validationError = 'Passwords do not match.');
      return;
    }
    setState(() => _validationError = null);
    context.read<AuthBloc>().add(AuthEvent.setupSubmitted(password));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            setState(() => _validationError = state.message);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/bg-auth.jpg', fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.55)),
            Center(
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/dental-service.ico',
                        width: 64, height: 64),
                    const SizedBox(height: 12),
                    Text('Set Up Password',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Create a password to protect your dental records.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    PasswordField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      labelText: 'New Password',
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_confirmFocus),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmController,
                      focusNode: _confirmFocus,
                      labelText: 'Confirm Password',
                      errorText: _validationError,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final loading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Set Password'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
