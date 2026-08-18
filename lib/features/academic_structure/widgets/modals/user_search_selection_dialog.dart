import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../auth/models/user_model.dart';
import '../../../users/providers/users_provider.dart';

class UserSearchSelectionDialog extends ConsumerStatefulWidget {
  final String title;
  final bool isAdviser; // If true, searches only advisers/instructors
  final UserModel? initialUser;

  const UserSearchSelectionDialog({
    super.key,
    required this.title,
    this.isAdviser = false,
    this.initialUser,
  });

  @override
  ConsumerState<UserSearchSelectionDialog> createState() => _UserSearchSelectionDialogState();
}

class _UserSearchSelectionDialogState extends ConsumerState<UserSearchSelectionDialog> {
  Timer? _debounce;
  String _searchQuery = '';
  int _currentPage = 0;
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.initialUser;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSearchConfig = UserSearchConfig(
      query: _searchQuery,
      page: _currentPage,
      pageSize: 5,
      isAdviser: widget.isAdviser,
    );

    final usersAsync = ref.watch(paginatedUsersProvider(userSearchConfig));

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_search_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Text(widget.title),
          ],
        ),
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Search for a user by name, email, or school ID number.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search Box and List
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search name, email, or school ID...',
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textGrey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  if (_searchQuery.trim().isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Type a name or ID to search',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    )
                  else
                    usersAsync.when(
                      data: (users) {
                        return Column(
                          children: [
                            if (users.isEmpty)
                              const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text('No users found', style: TextStyle(color: AppColors.textGrey)),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: users.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  final isSelected = _selectedUser?.id == user.id;

                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                      child: user.avatarUrl == null ? const Icon(Icons.person, size: 14) : null,
                                    ),
                                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${user.schoolId} • ${user.email}'),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedUser = user;
                                      });
                                    },
                                  );
                                },
                              ),
                            
                            // Pagination Footer
                            if (users.isNotEmpty || _currentPage > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: AppColors.border)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: _currentPage == 0
                                          ? null
                                          : () => setState(() => _currentPage--),
                                      child: const Text('Previous'),
                                    ),
                                    Text('Page ${_currentPage + 1}'),
                                    TextButton(
                                      onPressed: users.length < 5
                                          ? null
                                          : () => setState(() => _currentPage++),
                                      child: const Text('Next'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        height: 180,
                        child: Center(child: FlickrLoader()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                      ),
                    ),
                ],
              ),
            ),
            
            // Selected User Display
            if (_selectedUser != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: _selectedUser!.avatarUrl != null ? NetworkImage(_selectedUser!.avatarUrl!) : null,
                      child: _selectedUser!.avatarUrl == null ? const Icon(Icons.person, size: 16) : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedUser!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_selectedUser!.schoolId} • ${_selectedUser!.email}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _selectedUser = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (widget.initialUser != null || _selectedUser != null)
          TextButton(
            onPressed: () => Navigator.pop(context, null), // Returns null to clear the assignment
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear Assignment'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedUser),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
