import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.setupRequired() = AuthSetupRequired;
  const factory AuthState.locked() = AuthLocked;
  const factory AuthState.authenticated() = AuthAuthenticated;
  const factory AuthState.failure(String message) = AuthFailure;
}
