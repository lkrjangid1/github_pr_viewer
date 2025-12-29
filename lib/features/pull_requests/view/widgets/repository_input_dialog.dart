import 'package:flutter/material.dart';

/// Dialog for inputting repository owner and name
class RepositoryInputDialog extends StatefulWidget {
  const RepositoryInputDialog({super.key});

  @override
  State<RepositoryInputDialog> createState() => _RepositoryInputDialogState();
}

class _RepositoryInputDialogState extends State<RepositoryInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController(text: 'flutter');
  final _repoController = TextEditingController(text: 'flutter');

  @override
  void dispose() {
    _ownerController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'owner': _ownerController.text.trim(),
        'repo': _repoController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Repository'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Owner TextField
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Owner',
                hintText: 'e.g., flutter',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter repository owner';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Repository TextField
            TextFormField(
              controller: _repoController,
              decoration: const InputDecoration(
                labelText: 'Repository',
                hintText: 'e.g., flutter',
                prefixIcon: Icon(Icons.folder_outlined),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter repository name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Example repositories chip
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('flutter/flutter'),
                  onPressed: () {
                    _ownerController.text = 'flutter';
                    _repoController.text = 'flutter';
                  },
                ),
                ActionChip(
                  label: const Text('facebook/react'),
                  onPressed: () {
                    _ownerController.text = 'facebook';
                    _repoController.text = 'react';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Fetch PRs'),
        ),
      ],
    );
  }
}
