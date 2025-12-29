import 'package:flutter/material.dart';
import 'package:github_pr_viewer/features/pull_requests/models/models.dart';
import 'package:intl/intl.dart';

/// Individual pull request list item card
class PullRequestListItem extends StatelessWidget {
  const PullRequestListItem({
    required this.pullRequest,
    super.key,
  });

  final PullRequest pullRequest;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Could navigate to PR details page here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PR #${pullRequest.number}: ${pullRequest.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PR Title
              Row(
                children: [
                  Icon(
                    Icons.merge_type,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pullRequest.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // PR Number
              const SizedBox(height: 8),
              Text(
                '#${pullRequest.number}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Description (if available)
              if (pullRequest.body != null &&
                  pullRequest.body!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  pullRequest.body!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Author and Date
              Row(
                children: [
                  // Author Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: pullRequest.user.avatarUrl.isNotEmpty
                        ? NetworkImage(pullRequest.user.avatarUrl)
                        : null,
                    child: pullRequest.user.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),

                  // Author Username
                  Expanded(
                    child: Text(
                      pullRequest.user.login,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Date
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(pullRequest.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
