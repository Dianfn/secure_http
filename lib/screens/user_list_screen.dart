import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  List<User> _users = [];
  List<User> _filteredUsers = [];
  Duration _timeout = ApiService.defaultTimeout;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.getUsers(timeout: _timeout);
      if (!mounted) return;

      setState(() {
        _users = users;
        _filteredUsers = _filterUsers(users, _searchController.text);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error is ApiException
            ? error.message
            : 'Terjadi kesalahan: $error';
      });
    }
  }

  List<User> _filterUsers(List<User> users, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return List<User>.from(users);
    }

    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(keyword) ||
              user.email.toLowerCase().contains(keyword),
        )
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredUsers = _filterUsers(_users, query);
    });
  }

  void _onTimeoutSelected(Duration timeout) {
    if (timeout == _timeout) return;

    setState(() {
      _timeout = timeout;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          PopupMenuButton<Duration>(
            tooltip: 'Atur timeout',
            icon: const Icon(Icons.timer_outlined),
            onSelected: _onTimeoutSelected,
            itemBuilder: (context) => const [
              PopupMenuItem<Duration>(
                value: Duration(seconds: 5),
                child: Text('Timeout 5 detik'),
              ),
              PopupMenuItem<Duration>(
                value: Duration(seconds: 10),
                child: Text('Timeout 10 detik'),
              ),
              PopupMenuItem<Duration>(
                value: Duration(seconds: 20),
                child: Text('Timeout 20 detik'),
              ),
            ],
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadUsers,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Timeout: ${_timeout.inSeconds} detik',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredUsers.length} pengguna',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _users.isEmpty
                ? 'Belum ada data pengguna.'
                : 'Tidak ada pengguna yang cocok dengan pencarian.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                ),
              ),
              title: Text(user.name),
              subtitle: Text('${user.email}\n${user.phone}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
