import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:github_pr_viewer/features/pull_requests/models/models.dart';
import 'package:github_pr_viewer/features/pull_requests/repository/pull_request_repository.dart';

part 'pull_requests_event.dart';
part 'pull_requests_state.dart';

/// Bloc responsible for managing pull requests state and business logic
class PullRequestsBloc extends Bloc<PullRequestsEvent, PullRequestsState> {
  PullRequestsBloc({
    required PullRequestRepository pullRequestRepository,
  })  : _pullRequestRepository = pullRequestRepository,
        super(const PullRequestsInitial()) {
    on<PullRequestsFetched>(_onPullRequestsFetched);
    on<PullRequestsRefreshed>(_onPullRequestsRefreshed);
  }

  final PullRequestRepository _pullRequestRepository;

  /// Handle fetching pull requests
  Future<void> _onPullRequestsFetched(
    PullRequestsFetched event,
    Emitter<PullRequestsState> emit,
  ) async {
    emit(const PullRequestsLoading());

    try {
      final pullRequests = await _pullRequestRepository.fetchPullRequests(
        owner: event.owner,
        repo: event.repo,
      );

      emit(
        PullRequestsSuccess(
          pullRequests: pullRequests,
          owner: event.owner,
          repo: event.repo,
        ),
      );
    } on PullRequestException catch (e) {
      emit(PullRequestsFailure(error: e.message));
    } catch (e) {
      emit(PullRequestsFailure(error: e.toString()));
    }
  }

  /// Handle refreshing pull requests (pull-to-refresh)
  Future<void> _onPullRequestsRefreshed(
    PullRequestsRefreshed event,
    Emitter<PullRequestsState> emit,
  ) async {
    // Keep the current state visible during refresh
    final currentState = state;

    try {
      final pullRequests = await _pullRequestRepository.fetchPullRequests(
        owner: event.owner,
        repo: event.repo,
      );

      emit(
        PullRequestsSuccess(
          pullRequests: pullRequests,
          owner: event.owner,
          repo: event.repo,
        ),
      );
    } on PullRequestException catch (e) {
      // If refresh fails and we have previous data, keep it and show snackbar
      if (currentState is PullRequestsSuccess) {
        emit(currentState);
      } else {
        emit(PullRequestsFailure(error: e.message));
      }
    } catch (e) {
      if (currentState is PullRequestsSuccess) {
        emit(currentState);
      } else {
        emit(PullRequestsFailure(error: e.toString()));
      }
    }
  }
}
