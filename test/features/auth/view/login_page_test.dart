import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_pr_viewer/features/auth/auth.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginPage', () {
    late AuthBloc authBloc;
    late AuthRepository authRepository;

    setUp(() {
      authBloc = MockAuthBloc();
      authRepository = MockAuthRepository();
    });

    testWidgets('renders LoginView', (tester) async {
      when(() => authBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: authRepository,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: LoginPage(),
            ),
          ),
        ),
      );

      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('displays title and description', (tester) async {
      when(() => authBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      expect(find.text('GitHub PR Viewer'), findsOneWidget);
      expect(
        find.text('View open pull requests from any public repository'),
        findsOneWidget,
      );
    });

    testWidgets('displays login button', (tester) async {
      when(() => authBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      expect(
        find.widgetWithText(FilledButton, 'Login'),
        findsOneWidget,
      );
    });

    testWidgets('adds LoginRequested event when login button is pressed',
        (tester) async {
      when(() => authBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      verify(() => authBloc.add(const LoginRequested())).called(1);
    });

    testWidgets('shows loading indicator when state is AuthLoading',
        (tester) async {
      when(() => authBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('disables login button when state is AuthLoading',
        (tester) async {
      when(() => authBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows snackbar on AuthFailure', (tester) async {
      whenListen(
        authBloc,
        Stream<AuthState>.fromIterable([
          const Unauthenticated(),
          const AuthFailure(error: 'Login failed'),
        ]),
        initialState: const Unauthenticated(),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Login failed: Login failed'), findsOneWidget);
    });

    testWidgets('displays demo mode info card', (tester) async {
      when(() => authBloc.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: LoginView(),
          ),
        ),
      );

      expect(find.text('Demo Mode'), findsOneWidget);
      expect(
        find.textContaining('simulated token'),
        findsOneWidget,
      );
    });
  });
}
