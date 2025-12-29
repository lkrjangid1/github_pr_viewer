import 'package:equatable/equatable.dart';
import 'package:github_pr_viewer/features/pull_requests/models/user.dart';

/// Represents a GitHub Pull Request
class PullRequest extends Equatable {
  const PullRequest({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.user,
    required this.createdAt,
    required this.htmlUrl,
    required this.state,
  });

  /// Creates a PullRequest from GitHub API JSON response
  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
      id: json['id'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      htmlUrl: json['html_url'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
    );
  }

  final int id;
  final int number;
  final String title;
  final String? body;
  final User user;
  final DateTime createdAt;
  final String htmlUrl;
  final String state;

  /// Converts PullRequest to JSON (for testing/serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'body': body,
      'user': user.toJson(),
      'created_at': createdAt.toIso8601String(),
      'html_url': htmlUrl,
      'state': state,
    };
  }

  @override
  List<Object?> get props => [
        id,
        number,
        title,
        body,
        user,
        createdAt,
        htmlUrl,
        state,
      ];
}
