part of 'auth_bloc.dart';

/// Base class for all authentication events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event to check current authentication status on app start
final class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Event triggered when user attempts to login
final class LoginRequested extends AuthEvent {
  const LoginRequested();
}

/// Event triggered when user logs out
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
