import 'dart:convert';

import 'package:github_pr_viewer/features/pull_requests/models/models.dart';
import 'package:http/http.dart' as http;

/// Exception thrown when fetching pull requests fails
class PullRequestException implements Exception {
  PullRequestException(this.message);

  final String message;

  @override
  String toString() => 'PullRequestException: $message';
}

/// Repository responsible for fetching pull requests from GitHub API
class PullRequestRepository {
  PullRequestRepository({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const String _baseUrl = 'https://api.github.com';

  /// Fetches open pull requests for a given repository
  ///
  /// [owner] - The owner of the repository (e.g., 'flutter')
  /// [repo] - The repository name (e.g., 'flutter')
  ///
  /// Returns a list of [PullRequest] objects
  /// Throws [PullRequestException] if the request fails
  Future<List<PullRequest>> fetchPullRequests({
    required String owner,
    required String repo,
  }) async {
    if (owner.isEmpty || repo.isEmpty) {
      throw PullRequestException('Owner and repo cannot be empty');
    }

    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/pulls');

    try {
      final response = await _httpClient.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;

        return jsonList
            .map((json) => PullRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        throw PullRequestException(
          'Repository not found. Please check the owner and repo name.',
        );
      } else if (response.statusCode == 403) {
        throw PullRequestException(
          'API rate limit exceeded. Please try again later.',
        );
      } else {
        throw PullRequestException(
          'Failed to fetch pull requests: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PullRequestException) {
        rethrow;
      }
      throw PullRequestException('Network error: $e');
    }
  }
}
