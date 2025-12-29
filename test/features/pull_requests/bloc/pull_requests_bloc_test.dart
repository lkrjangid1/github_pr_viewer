import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_pr_viewer/features/pull_requests/pull_requests.dart';
import 'package:mocktail/mocktail.dart';

class MockPullRequestRepository extends Mock
    implements PullRequestRepository {}

void main() {
  group('PullRequestsBloc', () {
    late PullRequestRepository pullRequestRepository;

    final mockPullRequests = [
      PullRequest(
        id: 1,
        number: 123,
        title: 'Test PR 1',
        body: 'Description 1',
        user: const User(login: 'user1', avatarUrl: 'https://example.com/1'),
        createdAt: DateTime(2024),
        htmlUrl: 'https://github.com/test/test/pull/123',
        state: 'open',
      ),
      PullRequest(
        id: 2,
        number: 124,
        title: 'Test PR 2',
        body: null,
        user: const User(login: 'user2', avatarUrl: 'https://example.com/2'),
        createdAt: DateTime(2024, 1, 2),
        htmlUrl: 'https://github.com/test/test/pull/124',
        state: 'open',
      ),
    ];

    setUp(() {
      pullRequestRepository = MockPullRequestRepository();
    });

    test('initial state is PullRequestsInitial', () {
      final bloc = PullRequestsBloc(
        pullRequestRepository: pullRequestRepository,
      );
      expect(bloc.state, equals(const PullRequestsInitial()));
    });

    group('PullRequestsFetched', () {
      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits [PullRequestsLoading, PullRequestsSuccess] '
        'when fetching pull requests succeeds',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'flutter',
              repo: 'flutter',
            ),
          ).thenAnswer((_) async => mockPullRequests);
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        act: (bloc) => bloc.add(
          const PullRequestsFetched(owner: 'flutter', repo: 'flutter'),
        ),
        expect: () => [
          const PullRequestsLoading(),
          PullRequestsSuccess(
            pullRequests: mockPullRequests,
            owner: 'flutter',
            repo: 'flutter',
          ),
        ],
        verify: (_) {
          verify(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'flutter',
              repo: 'flutter',
            ),
          ).called(1);
        },
      );

      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits [PullRequestsLoading, PullRequestsSuccess] with empty list '
        'when repository has no open PRs',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'test',
              repo: 'repo',
            ),
          ).thenAnswer((_) async => []);
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        act: (bloc) => bloc.add(
          const PullRequestsFetched(owner: 'test', repo: 'repo'),
        ),
        expect: () => [
          const PullRequestsLoading(),
          const PullRequestsSuccess(
            pullRequests: [],
            owner: 'test',
            repo: 'repo',
          ),
        ],
      );

      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits [PullRequestsLoading, PullRequestsFailure] '
        'when fetching pull requests fails with PullRequestException',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'invalid',
              repo: 'repo',
            ),
          ).thenThrow(
            PullRequestException('Repository not found'),
          );
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        act: (bloc) => bloc.add(
          const PullRequestsFetched(owner: 'invalid', repo: 'repo'),
        ),
        expect: () => [
          const PullRequestsLoading(),
          const PullRequestsFailure(error: 'Repository not found'),
        ],
      );

      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits [PullRequestsLoading, PullRequestsFailure] '
        'when fetching pull requests fails with generic exception',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'test',
              repo: 'repo',
            ),
          ).thenThrow(Exception('Network error'));
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        act: (bloc) => bloc.add(
          const PullRequestsFetched(owner: 'test', repo: 'repo'),
        ),
        expect: () => [
          const PullRequestsLoading(),
          const PullRequestsFailure(error: 'Exception: Network error'),
        ],
      );
    });

    group('PullRequestsRefreshed', () {
      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits [PullRequestsSuccess] when refresh succeeds',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'flutter',
              repo: 'flutter',
            ),
          ).thenAnswer((_) async => mockPullRequests);
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        act: (bloc) => bloc.add(
          const PullRequestsRefreshed(owner: 'flutter', repo: 'flutter'),
        ),
        expect: () => [
          PullRequestsSuccess(
            pullRequests: mockPullRequests,
            owner: 'flutter',
            repo: 'flutter',
          ),
        ],
      );

      blocTest<PullRequestsBloc, PullRequestsState>(
        'keeps previous state when refresh fails and current state is success',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'flutter',
              repo: 'flutter',
            ),
          ).thenThrow(PullRequestException('Network error'));
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        seed: () => PullRequestsSuccess(
          pullRequests: mockPullRequests,
          owner: 'flutter',
          repo: 'flutter',
        ),
        act: (bloc) => bloc.add(
          const PullRequestsRefreshed(owner: 'flutter', repo: 'flutter'),
        ),
        // No new state is emitted since we're keeping the same state instance
        expect: () => <PullRequestsState>[],
        // Verify the state is still success after the failed refresh
        verify: (bloc) {
          expect(bloc.state, isA<PullRequestsSuccess>());
        },
      );

      blocTest<PullRequestsBloc, PullRequestsState>(
        'emits failure when refresh fails and current state is not success',
        setUp: () {
          when(
            () => pullRequestRepository.fetchPullRequests(
              owner: 'flutter',
              repo: 'flutter',
            ),
          ).thenThrow(PullRequestException('Network error'));
        },
        build: () => PullRequestsBloc(
          pullRequestRepository: pullRequestRepository,
        ),
        seed: () => const PullRequestsInitial(),
        act: (bloc) => bloc.add(
          const PullRequestsRefreshed(owner: 'flutter', repo: 'flutter'),
        ),
        expect: () => [
          const PullRequestsFailure(error: 'Network error'),
        ],
      );
    });
  });
}
