import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:github_pr_viewer/features/auth/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc responsible for managing authentication state and business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  /// Check if user is already authenticated on app start
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final token = await _authRepository.getToken();
        emit(Authenticated(token: token ?? ''));
      } else {
        emit(const Unauthenticated());
      }
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  /// Handle login request by storing fake token
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.login();
      final token = await _authRepository.getToken();
      emit(Authenticated(token: token ?? ''));
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  /// Handle logout by clearing stored token
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      emit(const Unauthenticated());
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }
}
