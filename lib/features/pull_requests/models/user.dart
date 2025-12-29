import 'package:equatable/equatable.dart';

/// Represents a GitHub user (PR author)
class User extends Equatable {
  const User({
    required this.login,
    required this.avatarUrl,
  });

  /// Creates a User from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  final String login;
  final String avatarUrl;

  /// Converts User to JSON (for testing/serialization)
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'avatar_url': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [login, avatarUrl];
}
