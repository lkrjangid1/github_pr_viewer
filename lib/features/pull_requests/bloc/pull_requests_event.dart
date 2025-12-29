part of 'pull_requests_bloc.dart';

/// Base class for all pull requests events
sealed class PullRequestsEvent extends Equatable {
  const PullRequestsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch pull requests for a repository
final class PullRequestsFetched extends PullRequestsEvent {
  const PullRequestsFetched({
    required this.owner,
    required this.repo,
  });

  final String owner;
  final String repo;

  @override
  List<Object> get props => [owner, repo];
}

/// Event to refresh pull requests (triggered by pull-to-refresh)
final class PullRequestsRefreshed extends PullRequestsEvent {
  const PullRequestsRefreshed({
    required this.owner,
    required this.repo,
  });

  final String owner;
  final String repo;

  @override
  List<Object> get props => [owner, repo];
}
