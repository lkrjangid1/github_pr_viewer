import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_pr_viewer/features/auth/auth.dart';
import 'package:github_pr_viewer/features/pull_requests/pull_requests.dart';
import 'package:github_pr_viewer/features/pull_requests/view/widgets/pull_request_list_item.dart';
import 'package:github_pr_viewer/features/pull_requests/view/widgets/repository_input_dialog.dart';

/// Pull Requests page that provides PullRequestsBloc and shows PR list
class PullRequestsPage extends StatelessWidget {
  const PullRequestsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const PullRequestsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PullRequestsBloc(
        pullRequestRepository: context.read<PullRequestRepository>(),
      ),
      child: const PullRequestsView(),
    );
  }
}

/// The actual Pull Requests UI implementation
class PullRequestsView extends StatefulWidget {
  const PullRequestsView({super.key});

  @override
  State<PullRequestsView> createState() => _PullRequestsViewState();
}

class _PullRequestsViewState extends State<PullRequestsView> {
  String _currentOwner = '';
  String _currentRepo = '';

  @override
  void initState() {
    super.initState();
    // Show dialog to get repository info on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRepositoryInputDialog();
    });
  }

  Future<void> _showRepositoryInputDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RepositoryInputDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _currentOwner = result['owner'] ?? '';
        _currentRepo = result['repo'] ?? '';
      });

      context.read<PullRequestsBloc>().add(
            PullRequestsFetched(
              owner: _currentOwner,
              repo: _currentRepo,
            ),
          );
    }
  }

  Future<void> _onRefresh() async {
    if (_currentOwner.isEmpty || _currentRepo.isEmpty) return;

    context.read<PullRequestsBloc>().add(
          PullRequestsRefreshed(
            owner: _currentOwner,
            repo: _currentRepo,
          ),
        );

    // Wait for the refresh to complete
    await context.read<PullRequestsBloc>().stream.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pull Requests'),
        actions: [
          // Change Repository Button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Change Repository',
            onPressed: _showRepositoryInputDialog,
          ),
          // Logout Button
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                // Navigate back to login page on logout
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<PullRequestsBloc, PullRequestsState>(
        listener: (context, state) {
          // Show error as snackbar during refresh
          if (state is PullRequestsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    if (_currentOwner.isNotEmpty && _currentRepo.isNotEmpty) {
                      context.read<PullRequestsBloc>().add(
                            PullRequestsFetched(
                              owner: _currentOwner,
                              repo: _currentRepo,
                            ),
                          );
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PullRequestsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PullRequestsSuccess) {
            if (state.pullRequests.isEmpty) {
              return _EmptyState(
                owner: _currentOwner,
                repo: _currentRepo,
                onChangeRepo: _showRepositoryInputDialog,
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.pullRequests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pr = state.pullRequests[index];
                  return PullRequestListItem(pullRequest: pr);
                },
              ),
            );
          }

          if (state is PullRequestsFailure) {
            return _ErrorState(
              error: state.error,
              onRetry: () {
                if (_currentOwner.isNotEmpty && _currentRepo.isNotEmpty) {
                  context.read<PullRequestsBloc>().add(
                        PullRequestsFetched(
                          owner: _currentOwner,
                          repo: _currentRepo,
                        ),
                      );
                }
              },
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Widget shown when there are no pull requests
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.owner,
    required this.repo,
    required this.onChangeRepo,
  });

  final String owner;
  final String repo;
  final VoidCallback onChangeRepo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Open Pull Requests',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'The repository $owner/$repo has no open pull requests.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onChangeRepo,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Try Different Repository'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget shown when there's an error
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
