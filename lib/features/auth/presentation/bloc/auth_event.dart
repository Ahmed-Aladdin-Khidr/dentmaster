import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkRequested() = AuthCheckRequested;
  const factory AuthEvent.passwordSubmitted(String password) =
      AuthPasswordSubmitted;
  const factory AuthEvent.setupSubmitted(String password) = AuthSetupSubmitted;
  const factory AuthEvent.changePasswordSubmitted(
      String currentPassword, String newPassword) = AuthChangePasswordSubmitted;
}
