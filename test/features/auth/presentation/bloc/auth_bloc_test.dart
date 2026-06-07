import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dentmaster/features/auth/domain/usecases/change_password.dart';
import 'package:dentmaster/features/auth/domain/usecases/is_password_set.dart';
import 'package:dentmaster/features/auth/domain/usecases/setup_password.dart';
import 'package:dentmaster/features/auth/domain/usecases/verify_password.dart';
import 'package:dentmaster/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dentmaster/features/auth/presentation/bloc/auth_event.dart';
import 'package:dentmaster/features/auth/presentation/bloc/auth_state.dart';

class MockIsPasswordSet extends Mock implements IsPasswordSet {}

class MockSetupPassword extends Mock implements SetupPassword {}

class MockVerifyPassword extends Mock implements VerifyPassword {}

class MockChangePassword extends Mock implements ChangePassword {}

AuthBloc _makeBloc({
  required MockIsPasswordSet isPasswordSet,
  required MockSetupPassword setupPassword,
  required MockVerifyPassword verifyPassword,
  required MockChangePassword changePassword,
}) =>
    AuthBloc(
      isPasswordSet: isPasswordSet,
      setupPassword: setupPassword,
      verifyPassword: verifyPassword,
      changePassword: changePassword,
    );

void main() {
  late MockIsPasswordSet mockIsPasswordSet;
  late MockSetupPassword mockSetupPassword;
  late MockVerifyPassword mockVerifyPassword;
  late MockChangePassword mockChangePassword;
  late AuthBloc bloc;

  setUp(() {
    mockIsPasswordSet = MockIsPasswordSet();
    mockSetupPassword = MockSetupPassword();
    mockVerifyPassword = MockVerifyPassword();
    mockChangePassword = MockChangePassword();
    bloc = _makeBloc(
      isPasswordSet: mockIsPasswordSet,
      setupPassword: mockSetupPassword,
      verifyPassword: mockVerifyPassword,
      changePassword: mockChangePassword,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is AuthInitial', () {
    expect(bloc.state, isA<AuthInitial>());
  });

  group('AuthCheckRequested', () {
    test('emits [loading, locked] when password is set', () async {
      when(() => mockIsPasswordSet()).thenAnswer((_) async => true);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.checkRequested());
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthLocked>()]);
    });

    test('emits [loading, setupRequired] when password is not set', () async {
      when(() => mockIsPasswordSet()).thenAnswer((_) async => false);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.checkRequested());
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthSetupRequired>()]);
    });

    test('emits [loading, failure] when isPasswordSet throws', () async {
      when(() => mockIsPasswordSet()).thenThrow(Exception('storage error'));

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.checkRequested());
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthFailure>()]);
    });
  });

  group('AuthPasswordSubmitted', () {
    test('emits [loading, authenticated] when password is correct', () async {
      when(() => mockVerifyPassword('secret')).thenAnswer((_) async => true);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.passwordSubmitted('secret'));
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);
    });

    test('emits [loading, failure] when password is incorrect', () async {
      when(() => mockVerifyPassword('wrong')).thenAnswer((_) async => false);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.passwordSubmitted('wrong'));
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ]);
      expect((states.last as AuthFailure).message,
          'Incorrect password. Please try again.');
    });
  });

  group('AuthSetupSubmitted', () {
    test('emits [loading, authenticated] after setup', () async {
      when(() => mockSetupPassword('newpass')).thenAnswer((_) async {});

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.setupSubmitted('newpass'));
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);
    });
  });

  group('AuthChangePasswordSubmitted', () {
    test('emits [loading, authenticated] on successful change', () async {
      when(() => mockChangePassword('old', 'new')).thenAnswer((_) async {});

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.changePasswordSubmitted('old', 'new'));
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);
    });

    test('emits [loading, failure] when current password is wrong', () async {
      when(() => mockChangePassword('bad', 'new'))
          .thenThrow(Exception('Current password is incorrect.'));

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthEvent.changePasswordSubmitted('bad', 'new'));
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<AuthLoading>(), isA<AuthFailure>()]);
      expect((states.last as AuthFailure).message,
          'Current password is incorrect.');
    });
  });
}
