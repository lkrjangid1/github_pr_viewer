part of 'auth_bloc.dart';

/// Base class for all authentication states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when auth status is being checked
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is in progress (loading)
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
final class Authenticated extends AuthState {
  const Authenticated({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

/// State when user is not authenticated
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication fails
final class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
