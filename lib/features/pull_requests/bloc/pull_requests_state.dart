part of 'pull_requests_bloc.dart';

/// Base class for all pull requests states
sealed class PullRequestsState extends Equatable {
  const PullRequestsState();

  @override
  List<Object> get props => [];
}

/// Initial state before any pull requests are fetched
final class PullRequestsInitial extends PullRequestsState {
  const PullRequestsInitial();
}

/// State when pull requests are being fetched
final class PullRequestsLoading extends PullRequestsState {
  const PullRequestsLoading();
}

/// State when pull requests are successfully loaded
final class PullRequestsSuccess extends PullRequestsState {
  const PullRequestsSuccess({
    required this.pullRequests,
    this.owner = '',
    this.repo = '',
  });

  final List<PullRequest> pullRequests;
  final String owner;
  final String repo;

  @override
  List<Object> get props => [pullRequests, owner, repo];
}

/// State when fetching pull requests fails
final class PullRequestsFailure extends PullRequestsState {
  const PullRequestsFailure({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}
