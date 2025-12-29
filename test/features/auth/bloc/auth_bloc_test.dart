import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_pr_viewer/features/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
    });

    test('initial state is AuthInitial', () {
      final authBloc = AuthBloc(authRepository: authRepository);
      expect(authBloc.state, equals(const AuthInitial()));
    });

    group('AuthStatusChecked', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when user is authenticated',
        setUp: () {
          when(() => authRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => authRepository.getToken())
              .thenAnswer((_) async => 'abc123');
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const AuthStatusChecked()),
        expect: () => [
          const AuthLoading(),
          const Authenticated(token: 'abc123'),
        ],
        verify: (_) {
          verify(() => authRepository.isAuthenticated()).called(1);
          verify(() => authRepository.getToken()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when user is not authenticated',
        setUp: () {
          when(() => authRepository.isAuthenticated())
              .thenAnswer((_) async => false);
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const AuthStatusChecked()),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => authRepository.isAuthenticated()).called(1);
          verifyNever(() => authRepository.getToken());
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when checking auth fails',
        setUp: () {
          when(() => authRepository.isAuthenticated())
              .thenThrow(Exception('Storage error'));
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const AuthStatusChecked()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(error: 'Exception: Storage error'),
        ],
      );
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when login succeeds',
        setUp: () {
          when(() => authRepository.login()).thenAnswer((_) async {});
          when(() => authRepository.getToken())
              .thenAnswer((_) async => 'abc123');
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const LoginRequested()),
        expect: () => [
          const AuthLoading(),
          const Authenticated(token: 'abc123'),
        ],
        verify: (_) {
          verify(() => authRepository.login()).called(1);
          verify(() => authRepository.getToken()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails',
        setUp: () {
          when(() => authRepository.login())
              .thenThrow(Exception('Login failed'));
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const LoginRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(error: 'Exception: Login failed'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when logout succeeds',
        setUp: () {
          when(() => authRepository.logout()).thenAnswer((_) async {});
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => authRepository.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when logout fails',
        setUp: () {
          when(() => authRepository.logout())
              .thenThrow(Exception('Logout failed'));
        },
        build: () => AuthBloc(authRepository: authRepository),
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthFailure(error: 'Exception: Logout failed'),
        ],
      );
    });
  });
}
