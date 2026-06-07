// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/is_password_set.dart';
import '../../domain/usecases/setup_password.dart';
import '../../domain/usecases/verify_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IsPasswordSet _isPasswordSet;
  final SetupPassword _setupPassword;
  final VerifyPassword _verifyPassword;
  final ChangePassword _changePassword;

  AuthBloc({
    required IsPasswordSet isPasswordSet,
    required SetupPassword setupPassword,
    required VerifyPassword verifyPassword,
    required ChangePassword changePassword,
  })  : _isPasswordSet = isPasswordSet,
        _setupPassword = setupPassword,
        _verifyPassword = verifyPassword,
        _changePassword = changePassword,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPasswordSubmitted>(_onPasswordSubmitted);
    on<AuthSetupSubmitted>(_onSetupSubmitted);
    on<AuthChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final isSet = await _isPasswordSet();
      emit(isSet ? const AuthState.locked() : const AuthState.setupRequired());
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onPasswordSubmitted(
      AuthPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final ok = await _verifyPassword(event.password);
      emit(ok
          ? const AuthState.authenticated()
          : const AuthState.failure('Incorrect password. Please try again.'));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onSetupSubmitted(
      AuthSetupSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _setupPassword(event.password);
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onChangePasswordSubmitted(
      AuthChangePasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _changePassword(event.currentPassword, event.newPassword);
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.failure(
          e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
